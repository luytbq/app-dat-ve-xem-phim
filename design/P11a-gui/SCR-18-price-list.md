# P11a - SCR-18 Bảng giá cụm rạp (Cinema price list) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.1 |
| Đầu vào đã dùng | ui-standards.md 1.1; screen-list.md 1.1; screen-transition.md 1.1; P04 UC-013 1.2 (bước 1-6, luồng 1a, 4a, 5a, *a, Dữ liệu vào 1, 2, Dữ liệu ra 1, 2); P05 GL-01, GL-22, GL-33; P08-analysis-model.md 1.1 (F3); P10-design-elements.md 1.1 (F3, F4) |
| Phạm vi | SCR-18 |
| Mã Q, ASM cuối đã cấp | Q-125; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-18 |
| UC | UC-013 |
| Bước UC | 1, 2, 3, 4, 5, 6; luồng 1a, 1a1-1a4, 4a, 5a, *a |
| Tác nhân | ACT-04 Quản lý cụm rạp |
| Boundary AC | AC-B-ManagePriceListForm |
| DC | DC-ManagePriceListView, DC-ManagePriceListStore |
| Loại màn hình | Độc lập |
| Đến từ | SCR-17 (E-29) |
| Đi tới | Không có cạnh đi; màn hình kết thúc, thoát bằng menu tới SCR-17 |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------------+
| CineBook   Trang chủ                                         |
|------------------------------------------------------------|
| Bảng giá cụm rạp                                             |
| (vùng thông điệp: MSG-51 đến MSG-57, MSG-76)                 |
| Loại phòng | Định dạng | Loại ghế | Khung giờ chiếu    | Giá vé     |
|------------+-----------+----------+--------------------+-----------|
| IMAX       | 3D        | Ghế VIP  | Cuối tuần từ 17 giờ| 150.000 đ [Bỏ giá]|
| Thường     | 2D        | Ghế thường| Ngày thường trước 17 giờ | 80.000 đ [Bỏ giá]|
|                                                              |
| Đặt giá                                                      |
| Loại phòng * [ IMAX v ]   Định dạng * [ 3D v ]                |
| Loại ghế *   [ Ghế VIP v ] Khung giờ chiếu * [ Cuối tuần từ 17 giờ v ] |
| Giá vé (đ) * [ 150000        ]                                |
|                          [ Huỷ yêu cầu ]  [ Lưu giá ]         |
+------------------------------------------------------------+
Hộp xác nhận (MSG-56): Bỏ mục giá IMAX, 3D, Ghế VIP, Cuối tuần từ 17 giờ? ... [ Giữ lại ] [ Bỏ giá ]
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Tiêu đề | h1 "Bảng giá cụm rạp" | Đầu nội dung | UI-STT 09 |
| Thông điệp | MSG-51 đến MSG-57, MSG-76 | Dưới tiêu đề | UI-STT 08 |
| Bảng giá | Bảng các mục giá, mỗi hàng một nút Bỏ giá | Trên | UC-013 Dữ liệu ra 1 |
| Biểu mẫu Đặt giá | Bốn danh sách chọn, ô giá vé | Dưới bảng | UC-013 Dữ liệu vào 1 |
| Hành động | Huỷ yêu cầu, Lưu giá | Cuối biểu mẫu, căn phải | UI-STT 06 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Tải và hiện bảng giá hiện tại của cụm rạp mà quản lý thuộc về, ghi nhận mốc hiển thị của từng mục giá. Bảng rỗng: MSG-76 | UC-013 bước 2, 1a1; BR-61, BR-63; MSG-76 |
| 2 | Bảng giá | Bảng | Khởi tạo | Mỗi hàng: loại phòng, định dạng phim, loại ghế, khung giờ chiếu, giá vé căn phải | UC-013 Dữ liệu ra 1 STT 1 |
| 3 | Danh sách Loại phòng, Định dạng, Loại ghế, Khung giờ chiếu | Danh sách chọn | Chọn | Chọn tổ hợp bốn yếu tố cần đặt giá | UC-013 bước 3, Dữ liệu vào 1 STT 1-4; BR-62 |
| 4 | Ô Giá vé | Ô nhập | Rời trường | Kiểm bắt buộc (MSG-03) rồi số nguyên đồng lớn hơn 0 (MSG-51) | UC-013 bước 4, 4a; BR-70; MSG-03, MSG-51 |
| 5 | Nút Lưu giá | Nút chính | Nhấn | Kiểm các trường theo UI-STT 19, gửi. Thành công: hiện MSG-54, cập nhật hàng của tổ hợp trong bảng và tô viền hàng đó. Mục giá đã bị yêu cầu khác đổi: MSG-52 và tải lại bảng giá. Giá không hợp lệ: MSG-51, ở lại biểu mẫu | UC-013 bước 5, 6, luồng 4a, 5a; BR-63, BR-66, BR-70; MSG-51, MSG-52, MSG-54 |
| 6 | Nút Huỷ yêu cầu | Nút phụ | Nhấn | Xoá nội dung đang nhập của biểu mẫu, bảng giá không đổi, hiện MSG-57 | UC-013 luồng *a; MSG-57 |
| 7 | Nút Bỏ giá (mỗi hàng) | Nút phụ | Nhấn | Mở hộp xác nhận MSG-56 nêu mục giá | UC-013 luồng 1a2; MSG-56; UI-STT 37 |
| 8 | Nút Bỏ giá (hộp xác nhận) | Nút chính phá huỷ | Nhấn | Gửi yêu cầu bỏ giá. Thành công: MSG-55 và bỏ hàng khỏi bảng. Mục giá đã đổi: MSG-52, tải lại bảng. Còn suất chiếu chưa tới giờ đang dùng mục giá: MSG-53, bảng giữ nguyên | UC-013 luồng 1a3, 1a3a, 1a3b, 1a4; BR-63, BR-64, BR-68; MSG-52, MSG-53, MSG-55 |
| 9 | Nút Giữ lại (hộp xác nhận) | Nút phụ | Nhấn | Đóng hộp, không bỏ giá | UI-STT 37 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Loại phòng | - | Lựa chọn | Chọn, bắt buộc | Phòng thường, 4DX hoặc IMAX | - | UC-013 Dữ liệu vào 1 STT 1; BR-62 |
| Định dạng phim | - | Lựa chọn | Chọn, bắt buộc | 2D hoặc 3D | - | UC-013 Dữ liệu vào 1 STT 2; BR-62 |
| Loại ghế | - | Lựa chọn | Chọn, bắt buộc | Ghế thường, ghế VIP hoặc ghế đôi; giá ghế đôi là giá một vé | - | UC-013 Dữ liệu vào 1 STT 3 |
| Khung giờ chiếu | - | Lựa chọn | Chọn, bắt buộc | Ngày thường trước 17 giờ; ngày thường từ 17 giờ; cuối tuần trước 17 giờ; cuối tuần từ 17 giờ (cuối tuần gồm Thứ Bảy, Chủ nhật) | - | UC-013 Dữ liệu vào 1 STT 4; BR-11, BR-12 |
| Giá vé | 9 | Tiền | Nhập, bắt buộc, căn phải | Số nguyên đồng lớn hơn 0, tối đa 9 chữ số (dưới 1 tỉ đồng) | Nhập chữ số, bỏ dấu chấm và khoảng trắng khi gửi; ví dụ 120000 | UC-013 Dữ liệu vào 1 STT 5; BR-70; Q-124 (Thiết kế: 9 chữ số) |
| Mục giá cần bỏ | - | Lựa chọn | Chọn, bắt buộc | Một mục giá của bảng giá cụm rạp mình | - | UC-013 Dữ liệu vào 2 STT 1; BR-61 |
| Giá vé hiển thị trong bảng | 15 (Thiết kế: đủ cho 999.999.999 đ) | Tiền | Hiển thị, căn phải | Số nguyên đồng, dấu chấm hàng nghìn, " đ" | - | UC-013 Dữ liệu ra 1 STT 1, Dữ liệu ra 2 STT 1 |

## f) Kiểm tra dữ liệu nhập

| Trường | Thời điểm kiểm tra | Kiểm tra | MSG khi lỗi |
|---|---|---|---|
| Bốn danh sách chọn | Rời trường; nhấn Lưu giá | Bắt buộc có giá trị | MSG-03 |
| Giá vé | Rời trường; nhấn Lưu giá | Bắt buộc --> chữ số --> số nguyên lớn hơn 0 và không quá 9 chữ số | MSG-03; MSG-51 |
| Mục giá | Nhấn Lưu giá, Bỏ giá (hệ thống) | Chưa bị yêu cầu khác đổi --> không còn suất chiếu đang dùng khi bỏ | MSG-52; MSG-53 |

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-18 | Nielsen 5 Ngăn lỗi | Đạt | Xác nhận trước khi bỏ giá (MSG-56); danh sách chọn thay ô gõ cho bốn yếu tố tổ hợp | - |
| SCR-18 | Nielsen 4 Nhất quán | Đạt | Bố cục bảng và biểu mẫu thống nhất với SCR-19 | - |
| SCR-18 | Baymard: một cột, nhãn trên ô, bắt buộc có dấu * | Đạt | UI-STT 16 áp dụng cho biểu mẫu Đặt giá | - |
| SCR-18 | WCAG 1.4.1 | Đạt | Hàng vừa lưu có viền trái và biểu tượng, không chỉ màu (UI-STT 18) | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 17-21, 27-31, 33-35, 37.

## h) Thông điệp mới

Không có.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-124.

## Đề xuất sửa artifact trước

Không có.

## Vấn đề còn mở

Giữ nguyên danh sách khi bị từ chối (UI-STT 29(2)).
