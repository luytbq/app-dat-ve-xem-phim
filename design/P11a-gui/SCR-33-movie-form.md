# P11a - SCR-33 Thêm hoặc sửa phim (Create or edit movie) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | ui-standards.md 2.0; screen-list.md 2.0; screen-transition.md 2.0; P04 UC-010 1.2 (bước 3-6, luồng 1a3, 4a, 5a, *a, Dữ liệu vào 1, Dữ liệu ra 2, 3, BR-134, BR-138); P05 GL-37; P07 UC-010; P08-analysis-model.md 2.0 (F3); P10-design-elements.md 2.0 (F3, F4). Dải Q của phiên: Q-272 đến Q-281 (C10) |
| Phạm vi | SCR-33 |
| Mã Q, ASM cuối đã cấp | Q-276; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-33 |
| UC | UC-010 |
| Bước UC | 3, 4, 5, 6; luồng 1a3, 4a, 5a, *a |
| Tác nhân | ACT-05 Quản lý chuỗi |
| Boundary AC | AC-B-ManageMoviesForm (enterMovieInfo, showMovieForEdit, showSavedMovie, notifyRefusal, cancelRequest) |
| DC | DC-ManageMoviesView |
| Loại màn hình | Con phụ thuộc (pop-up modal) |
| Đến từ | SCR-32 (E-56) |
| Đi tới | Đóng ngầm định về SCR-32 |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------+
| Thêm phim                                   [ Đóng ]    |
|------------------------------------------------------|
| (vùng thông điệp: MSG-03, MSG-95 đến MSG-98)           |
| * là bắt buộc                                          |
| Tên phim *            [ Mai                         ]  |
| Thể loại (không bắt buộc) [ Tâm lý, tình cảm        ]  |
| Thời lượng (phút) *   [ 131 ]                          |
| Độ tuổi được xem (không bắt buộc) [ T18 v ]            |
| Mô tả (không bắt buộc)                                 |
| [ Câu chuyện về một người phụ nữ ...               ]   |
| Trailer (không bắt buộc) [ https://video.example/mai-trailer ] |
| Định dạng phát hành *  [x] 2D   [x] 3D                 |
| Ngày khởi chiếu *     [ 15/12/2026 ]  dd/MM/yyyy       |
| Ngày kết thúc chiếu * [ 31/12/2026 ]  dd/MM/yyyy       |
|                      [ Huỷ yêu cầu ]  [ Lưu phim ]      |
+------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Tiêu đề | h2 trong hộp: "Thêm phim" hoặc "Sửa phim"; nút Đóng | Đầu hộp | UI-STT 09, 21, 50 |
| Thông điệp | MSG-03, MSG-95 đến MSG-98, MSG-72, MSG-73 | Dưới tiêu đề hộp | UI-STT 08 |
| Nội dung | Chín trường nhập | Giữa hộp, cuộn trong hộp | UC-010 Dữ liệu vào 1 |
| Hành động | Huỷ yêu cầu, Lưu phim | Cuối hộp, căn phải | UI-STT 06 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Hiện hộp modal. Thêm mới: các trường trống. Sửa: các trường mang thông tin hiện tại của phim | UC-010 bước 3, luồng 1a3, Dữ liệu ra 3 |
| 2 | Ô Tên phim | Ô nhập | Rời trường | Kiểm bắt buộc (MSG-03) | UC-010 Dữ liệu vào 1 STT 1 |
| 3 | Ô Thể loại, ô Mô tả, ô Trailer | Ô nhập | Rời trường | Không bắt buộc, không kiểm định dạng (trailer là đường dẫn văn bản) | UC-010 Dữ liệu vào 1 STT 2, 5, 6; Q-199 |
| 4 | Ô Thời lượng | Ô nhập | Rời trường | Kiểm bắt buộc (MSG-03), rồi số nguyên phút lớn hơn 0 (MSG-95) | UC-010 Dữ liệu vào 1 STT 3; Q-196 |
| 5 | Danh sách Độ tuổi được xem | Danh sách chọn | Chọn | Chọn P, K, T13, T16, T18 hoặc C; có mục "Chưa chọn" vì trường không bắt buộc | UC-010 Dữ liệu vào 1 STT 4; Q-198 |
| 6 | Ô chọn 2D, 3D | Ô chọn | Chọn | Chọn một hoặc cả hai định dạng phát hành. Không chọn ô nào khi nhấn Lưu: MSG-96 | UC-010 Dữ liệu vào 1 STT 7; BR-134 |
| 7 | Ô Ngày khởi chiếu, ô Ngày kết thúc chiếu | Ô nhập | Rời trường | Kiểm bắt buộc (MSG-03), rồi định dạng dd/MM/yyyy (MSG-97), rồi ngày kết thúc không trước ngày khởi chiếu, hai ngày bằng nhau hợp lệ (MSG-98) | UC-010 Dữ liệu vào 1 STT 8, 9; Q-197 |
| 8 | Nút Lưu phim | Nút chính | Nhấn | Kiểm các trường theo UI-STT 19, gửi (nút bận theo UI-STT 27). Từ chối từng trường ở lại hộp, giữ dữ liệu. Khi sửa mà phim đã bị người khác sửa kể từ lúc hiển thị: MSG-99 rồi đóng hộp, tải lại SCR-32. Thành công: MSG-100, đóng hộp, làm mới SCR-32 kèm phim đã lưu | UC-010 bước 4-6, luồng 4a, 5a; BR-134, BR-138; MSG-95 đến MSG-100 |
| 9 | Nút Huỷ yêu cầu, nút Đóng | Nút phụ | Nhấn | Đóng hộp không lưu, về SCR-32 và hiện MSG-57 | UC-010 luồng *a; MSG-57 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Tên phim | 200 | Chữ | Nhập, bắt buộc, căn trái | Không để trống; được trùng tên phim khác (Q-200) | Độ dài theo Q-273 | UC-010 Dữ liệu vào 1 STT 1; Q-200 |
| Thể loại | 50 | Chữ | Nhập, không bắt buộc, căn trái | Văn bản, nguồn không nêu danh mục thể loại | Độ dài theo Q-273 | UC-010 Dữ liệu vào 1 STT 2 |
| Thời lượng | 4 | Số | Nhập, bắt buộc, căn phải | Số nguyên phút lớn hơn 0, không có giá trị tối đa (Q-196) | Độ dài 4 chữ số theo Q-273; đơn vị phút ghi dưới nhãn | UC-010 Dữ liệu vào 1 STT 3; Q-196 |
| Độ tuổi được xem | - | Lựa chọn | Chọn, không bắt buộc | Một nhãn trong P, K, T13, T16, T18, C | - | UC-010 Dữ liệu vào 1 STT 4; Q-198 |
| Mô tả | 2000 | Chữ | Nhập, không bắt buộc, nhiều dòng | Văn bản | Độ dài theo Q-273 | UC-010 Dữ liệu vào 1 STT 5 |
| Trailer | 500 | Chữ | Nhập, không bắt buộc, căn trái | Đường dẫn dạng văn bản tới video đặt ngoài hệ thống | Độ dài theo Q-273 | UC-010 Dữ liệu vào 1 STT 6; Q-199 |
| Định dạng phát hành | - | Lựa chọn | Chọn, bắt buộc | Một hoặc cả hai định dạng 2D, 3D | - | UC-010 Dữ liệu vào 1 STT 7; BR-134 |
| Ngày khởi chiếu | 10 | Ngày | Nhập, bắt buộc, căn trái | dd/MM/yyyy; không sau ngày kết thúc chiếu | Gợi ý định dạng dưới nhãn | UC-010 Dữ liệu vào 1 STT 8; Q-197 |
| Ngày kết thúc chiếu | 10 | Ngày | Nhập, bắt buộc, căn trái | dd/MM/yyyy; không trước ngày khởi chiếu, hai ngày bằng nhau hợp lệ | Gợi ý định dạng dưới nhãn | UC-010 Dữ liệu vào 1 STT 9; Q-197 |

## f) Kiểm tra dữ liệu nhập

| Trường | Thời điểm kiểm tra | Kiểm tra | MSG khi lỗi |
|---|---|---|---|
| Tên phim | Rời trường; nhấn Lưu | Bắt buộc | MSG-03 |
| Thời lượng | Rời trường; nhấn Lưu | Bắt buộc --> số nguyên lớn hơn 0 | MSG-03; MSG-95 |
| Định dạng phát hành | Nhấn Lưu | Ít nhất một định dạng | MSG-96 |
| Ngày khởi chiếu | Rời trường; nhấn Lưu | Bắt buộc --> định dạng dd/MM/yyyy | MSG-03; MSG-97 |
| Ngày kết thúc chiếu | Rời trường; nhấn Lưu | Bắt buộc --> định dạng --> không trước ngày khởi chiếu | MSG-03; MSG-97; MSG-98 |
| Phim đang sửa | Nhấn Lưu (hệ thống) | Chưa bị yêu cầu khác sửa kể từ lúc hiển thị | MSG-99 |

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-33 | Nielsen 5 Ngăn lỗi | Đạt | Danh sách chọn cho độ tuổi, ô chọn cho định dạng, gợi ý định dạng ngày dưới nhãn | - |
| SCR-33 | Nielsen 9 Nhận biết, chẩn đoán, khắc phục lỗi | Đạt | Mỗi điều kiện vi phạm có thông điệp riêng đặt cạnh trường (MSG-95 đến MSG-98) | - |
| SCR-33 | Baymard: một cột, nhãn trên ô, đánh dấu bắt buộc và tuỳ chọn, giữ dữ liệu khi lỗi | Đạt | UI-STT 16, 20 | - |
| SCR-33 | WCAG 2.4.3, 2.4.11 | Đạt | Tiêu điểm bị giữ trong hộp và trả về khi đóng (UI-STT 21, 50) | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 17-21, 25, 27-31, 33-35, 49.

## h) Thông điệp mới

Không có. MSG-95 đến MSG-100 cấp ở ui-standards.md.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-273.

## Đề xuất sửa artifact trước

Không có.

## Vấn đề còn mở

Không có.
