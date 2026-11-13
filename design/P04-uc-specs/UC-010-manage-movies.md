# P04 - Đặc tả use case UC-010 Quản lý phim - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P04 |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | 00-Conventions.md; 00-Concurrency.md (M1); project-profile.md; yeu-cau-dat-ve.md; P00-problem-brief.md 1.11; P01-actors.md 1.2; P02-usecases.md 1.8; P03-usecase-model.md 1.1; _BR-register.md (đầu lô; BR-01 đến BR-93); P05-glossary.md 1.1; P06-supplementary-spec.md 1.3; P08-analysis-model.md 1.5 (EX-13, EX-15); P13-data-model.md 1.5 (Q-136 đến Q-138); UC-005-book-tickets.md 1.13; UC-013-manage-price-list.md 1.3 (mẫu); UC-014-schedule-showtimes.md 1.5 (điểm nối). Dải mã được cấp cho phiên: Q-195 đến Q-214, BR-134 đến BR-153 |
| Phạm vi | UC-010 |
| Mã Q, ASM cuối đã cấp | Q-203 (dải Q-195 đến Q-214); không có ASM (NGHIEM_NGAT) |

## 1. Thông tin chung

| Thuộc tính | Giá trị |
|---|---|
| Mã use case | UC-010 |
| Tên use case | Quản lý phim (Manage Movies) |
| Tác nhân chính | ACT-05 Quản lý chuỗi |
| Tác nhân phụ | Không có |
| Mô tả ngắn | Use case này mô tả tương tác giữa quản lý chuỗi và hệ thống khi quản lý chuỗi muốn thêm phim mới hoặc sửa thông tin của một phim trong danh sách phim của chuỗi. Kết quả là danh sách phim có thông tin phim, định dạng phát hành, ngày khởi chiếu và ngày kết thúc chiếu đúng và đủ để lập lịch chiếu và để khách tra cứu. |
| Sự kiện kích hoạt | Chuỗi có phim mới hoặc thông tin phim thay đổi (EV-12) |
| Tiền điều kiện | Quản lý chuỗi đã đăng nhập và đang có phiên làm việc (REQ-102). |
| Hậu điều kiện (thành công) | Khi thêm phim (luồng chính): danh sách phim của chuỗi có thêm một phim với tên, thể loại, thời lượng, độ tuổi được xem, mô tả, trailer, các định dạng phát hành, ngày khởi chiếu và ngày kết thúc chiếu mà quản lý chuỗi đã nhập.<br>Khi sửa phim (luồng 1a): phim đã chọn có các giá trị mà quản lý chuỗi đã nhập thay cho giá trị cũ.<br>Trong cả hai trường hợp, phim được xếp vào phim sắp chiếu hoặc phim đang chiếu theo ngày khởi chiếu và ngày kết thúc chiếu mới (BR-76), và các suất chiếu đã lập của phim không đổi (BR-84). |
| Hậu điều kiện tối thiểu | Khi use case kết thúc thất bại, danh sách phim và thông tin của mọi phim không thay đổi. |
| Quan hệ | Không có |
| Điểm mở rộng | Không có |
| REQ | REQ-53, REQ-55, REQ-95 (theo P02); REQ-07 (P02 Mục 5 đã gắn UC-010); REQ-102 (tiền điều kiện; P02 ghi "-"); REQ-96 (tham chiếu, UC-003); REQ-97, REQ-98, REQ-144 (tham chiếu, UC-014); REQ-105 (tham chiếu, UC-005) |

## 2. Luồng sự kiện chính

| STT | Thực hiện bởi | Hành động |
|---|---|---|
| 1 | Quản lý chuỗi | Yêu cầu thêm phim mới vào danh sách phim của chuỗi. |
| 2 | Hệ thống | Hiển thị danh sách phim hiện có của chuỗi (xem Dữ liệu ra 1). |
| 3 | Quản lý chuỗi | Nhập thông tin phim, chọn các định dạng phát hành, nhập ngày khởi chiếu và ngày kết thúc chiếu rồi gửi (xem Dữ liệu vào 1; BR-134). |
| 4 | Hệ thống | Kiểm tra thông tin phim hợp lệ theo điều kiện của Dữ liệu vào 1 (điều kiện còn thiếu: Q-196, Q-197, Q-198, Q-199, Q-200). |
| 5 | Hệ thống | Lưu thông tin phim, thêm phim mới vào danh sách phim hoặc cập nhật phim đã chọn ở luồng 1a (xử lý khi phim đã bị sửa trong lúc chờ lưu: Q-201, Q-202). |
| 6 | Hệ thống | Thông báo lưu phim thành công và hiển thị phim đã lưu (xem Dữ liệu ra 2). |

## 3. Luồng sự kiện thay thế và ngoại lệ

| STT | Điều kiện | Thực hiện bởi | Hành động | Quay lại / Kết thúc |
|---|---|---|---|---|
| 1a | Quản lý chuỗi chọn sửa một phim đã có thay vì thêm phim mới | - | Sửa phim | - |
| 1a1 | | Hệ thống | Hiển thị danh sách phim của chuỗi (xem Dữ liệu ra 1). | |
| 1a2 | | Quản lý chuỗi | Chọn phim cần sửa (xem Dữ liệu vào 2). | |
| 1a3 | | Hệ thống | Hiển thị thông tin hiện tại của phim đã chọn để sửa (xem Dữ liệu ra 3). | Tiếp tục bước 3 |
| 4a | Thông tin phim không đạt điều kiện hợp lệ của Dữ liệu vào 1 | Hệ thống | Từ chối lưu và thông báo điều kiện bị vi phạm của từng trường (BR-134 với định dạng phát hành). | Quay lại bước 3 |
| *a | Tại bất kỳ bước nào trước bước 5, kể cả trong luồng 1a, quản lý chuỗi huỷ yêu cầu | Hệ thống | Huỷ yêu cầu, không thay đổi danh sách phim. | Kết thúc use case (thất bại) |

## 4. Luồng con

Không có

## 5. Dữ liệu vào và dữ liệu ra

Dữ liệu vào 1 (bước 3)

| STT | Trường dữ liệu | Mô tả | Bắt buộc | Điều kiện hợp lệ | Ví dụ |
|---|---|---|---|---|---|
| 1 | Tên phim | Tên của phim | Có (vé và email ghi tên phim, REQ-105) | Không để trống; việc trùng tên phim khác: chưa quy định (Q-200) | Mai |
| 2 | Thể loại | Thể loại của phim | Không (trả lời Q-137) | Văn bản; nguồn không nêu danh mục thể loại | Tâm lý, tình cảm |
| 3 | Thời lượng | Thời lượng chiếu của phim, đơn vị phút, dùng tính giờ kết thúc của suất chiếu (REQ-98) | Có | Số phút; miền giá trị: chưa quy định (Q-196) | 131 |
| 4 | Độ tuổi được xem | Độ tuổi được xem phim | Không (trả lời Q-137) | Chưa quy định (Q-198) | T18 |
| 5 | Mô tả | Mô tả nội dung phim | Không (trả lời Q-137) | Văn bản | Câu chuyện về một người phụ nữ... |
| 6 | Trailer | Trailer của phim | Chưa quy định (Q-199) | Chưa quy định (Q-199) | Chưa quy định (Q-199) |
| 7 | Định dạng phát hành | Các định dạng phim được phát hành | Có (REQ-55) | Một hoặc cả hai định dạng 2D, 3D (REQ-55, BR-134) | 2D, 3D |
| 8 | Ngày khởi chiếu | Ngày đầu tiên phim được chiếu (REQ-95) | Có | Ngày hợp lệ; quan hệ với ngày kết thúc chiếu: chưa quy định (Q-197) | 15/12/2026 |
| 9 | Ngày kết thúc chiếu | Ngày cuối cùng phim được chiếu (REQ-95) | Có | Ngày hợp lệ; quan hệ với ngày khởi chiếu: chưa quy định (Q-197) | 31/12/2026 |

Dữ liệu vào 2 (bước 1a2)

| STT | Trường dữ liệu | Mô tả | Bắt buộc | Điều kiện hợp lệ | Ví dụ |
|---|---|---|---|---|---|
| 1 | Phim cần sửa | Một phim trong danh sách ở Dữ liệu ra 1 | Có | Phim có trong danh sách phim của chuỗi | Mai |

Dữ liệu ra 1 (bước 2, bước 1a1)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Danh sách phim | Với mỗi phim: tên, thể loại, thời lượng, độ tuổi được xem, các định dạng phát hành, ngày khởi chiếu, ngày kết thúc chiếu (REQ-07, REQ-55, REQ-95) | Thời lượng là số nguyên kèm "phút"; ngày dạng dd/MM/yyyy; các định dạng phát hành cách nhau bằng dấu phẩy | Mai, Tâm lý, 131 phút, T18, 2D, 15/12/2026, 31/12/2026 |

Dữ liệu ra 2 (bước 6)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Phim đã lưu | Toàn bộ thông tin của phim vừa lưu: các trường của Dữ liệu vào 1 | Như Dữ liệu ra 1; mô tả và trailer là văn bản | Mai, Tâm lý, 131 phút, T18, 2D, 15/12/2026, 31/12/2026 |

Dữ liệu ra 3 (bước 1a3)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Thông tin hiện tại của phim | Toàn bộ thông tin hiện tại của phim đã chọn: các trường của Dữ liệu vào 1 | Như Dữ liệu ra 2 | Mai, Tâm lý, 131 phút, T18, 2D, 15/12/2026, 31/12/2026 |

## 6. Quy tắc nghiệp vụ

| BR | Quy tắc | Loại | Bước áp dụng | REQ | Trong sổ BR |
|---|---|---|---|---|---|
| BR-134 | Mỗi phim được phát hành ở một hoặc nhiều định dạng trong hai định dạng 2D, 3D. | Sự kiện | 3, 4a, Dữ liệu vào 1 (trường 7) | REQ-55 | Mới |
| BR-84 | Phim hoặc phòng chiếu thay đổi sau khi lập suất chiếu không làm suất chiếu đã lập tự đổi. | Ràng buộc | Hậu điều kiện, Mục 8 | REQ-144 | Đã có |
| BR-76 | Phim sắp chiếu là phim chưa tới ngày khởi chiếu; phim đang chiếu là phim đã tới ngày khởi chiếu và chưa qua ngày kết thúc chiếu. | Suy luận | Hậu điều kiện, Mục 8 | REQ-96; REQ-95 (phụ) | Đã có |

## 7. Yêu cầu đặc biệt

Không có

## 8. Thông tin bổ sung

- Luồng chính là kịch bản thêm phim mới và luồng 1a là sửa phim, theo hai vế của sự kiện kích hoạt EV-12 "phim mới hoặc thông tin phim thay đổi". Nguồn chỉ nêu "quản lý danh sách phim" (REQ-53) và P00 ghi không tách thao tác. Quản lý chuỗi chọn thêm hoặc sửa thay cho bước 1, nên trên activity diagram decision D-1 đặt ngay sau INIT, trước A-1. Luồng 1a quay về bước 3 để nhập giá trị mới; bước 4 đến bước 6 dùng chung cho cả hai thao tác.
- Thao tác xoá phim không có trong luồng nào: nguồn không nêu việc xoá và EV-12 không nêu (Q-195). Theo đề xuất của Q-195 danh sách phim chỉ có thêm và sửa, phim ngừng chiếu bằng cách sửa ngày kết thúc chiếu. Trả lời khác thì thêm luồng 1b (chọn phim, kiểm tra điều kiện được xoá, xoá) và đặc tả lại hậu điều kiện, BR liên quan.
- Thông tin phim gồm tên, thể loại, thời lượng, độ tuổi được xem, mô tả, trailer (REQ-07), các định dạng phát hành (REQ-55), ngày khởi chiếu và ngày kết thúc chiếu (REQ-95). Theo trả lời Q-137 (P13), thể loại, độ tuổi được xem và mô tả không bắt buộc. Trường nguồn chưa quy định điều kiện hợp lệ ghi "Chưa quy định (Q-nn)" ở Dữ liệu vào 1; luồng 4a gộp mọi điều kiện hợp lệ vì cùng một cách xử lý (F5.7).
- Sửa phim đã có suất chiếu không bị chặn: suất chiếu đã lập không tự đổi khi phim đổi thời lượng, định dạng phát hành hoặc khoảng chiếu (BR-84, trả lời Q-58). Giờ kết thúc đã tính ở UC-014 giữ nguyên khi thời lượng phim đổi (BR-50). BR-47, BR-49 và BR-50 của UC-014 chỉ kiểm hoặc tính khi lập hoặc sửa suất chiếu, nên một suất chiếu đã lập có thể có định dạng không còn là định dạng phát hành hoặc ngày chiếu ngoài khoảng chiếu mới; UC-014 kiểm lại khi quản lý cụm rạp sửa chính suất chiếu đó.
- Điểm nối với UC-014 (tranh chấp phim): UC-014 bước 5 đến bước 7 đọc định dạng phát hành, khoảng chiếu và thời lượng của phim, bước 8 lưu suất chiếu. Phim bị sửa xen vào giữa hai chỗ này chưa có quy định (Q-202); đề xuất là UC-014 bước 8 kiểm lại BR-47, BR-49 và tính lại BR-50 theo phim hiện hành trong cùng thao tác không chia cắt với việc lưu, giống cách BR-68 xử lý bảng giá.
- Tên phim, tên cụm rạp, tên phòng chiếu và loại phòng được ghi trên vé (REQ-105). Vé đã bán hiển thị giá trị lúc bán hay giá trị hiện hành khi phim đổi tên chưa quy định (Q-203). Đề xuất của Q-203 áp dụng chung cho UC-010, UC-011, UC-012.
- Danh sách phim sắp chiếu và đang chiếu cho khách (UC-003) lấy từ dữ liệu của use case này theo BR-76. Khách tra cứu trước hoặc sau khi lưu đều thấy dữ liệu hợp lệ nên không cần loại trừ.
- Bước sinh theo quy tắc của prompt: bước 6 (báo kết quả cho quản lý chuỗi); hành động "Từ chối ... và thông báo" ở luồng 4a; điểm quay lại bước 3 ở luồng 4a vì quản lý chuỗi sửa được dữ liệu vi phạm.
- Không có bước hẹn hoặc huỷ mốc (F4.2 mục 17): P01 không có tác nhân thời gian và không use case nào khởi động theo thời gian dùng dữ liệu phim làm mốc.

Thao tác nguyên tử

| Thao tác | Bước | Tài nguyên | Bất biến giữ được | Loại trừ với | Kết cục bên thua | Căn cứ |
|---|---|---|---|---|---|---|
| Lưu phim (thêm hoặc sửa) | 5 | Bản ghi của một phim, gồm các trường của Dữ liệu vào 1 | Phim được ghi trọn vẹn: mọi trường cùng lúc, không có phim nửa cũ nửa mới | Chính nó (hai yêu cầu sửa cùng một phim); UC-014 bước 8 (đọc phim để kiểm BR-47, BR-49, tính BR-50 khi lưu suất chiếu); UC-003, UC-004 (chưa đặc tả; chỉ đọc danh sách phim, không cần loại trừ) | Chính nó: chưa quy định (Q-201). UC-014: chưa quy định (Q-202). UC-003, UC-004: thấy phim trước hoặc sau khi lưu, cả hai đều hợp lệ | BR-84, REQ-144; Q-201, Q-202 |
| Thêm phim | 5 | Danh sách phim | Không có bất biến chung nào được nguồn nêu; việc trùng tên chờ Q-200 | Chính nó (hai yêu cầu thêm phim cùng lúc) | Cả hai phim cùng được thêm, trừ khi Q-200 cấm trùng tên | Q-200 |

## 8a. Kịch bản chính

- KB1: Luồng chính --> quản lý chuỗi thêm phim mới thành công.
- KB2: Luồng 1a --> quản lý chuỗi sửa thông tin phim đã có thành công; suất chiếu đã lập của phim không đổi.
- KB3: Luồng chính + 4a --> thông tin phim không hợp lệ, quay lại bước 3, nhập lại rồi lưu thành công.
- KB4: Luồng 1a + 4a --> sửa phim với thông tin không hợp lệ, quay lại bước 3, nhập lại rồi lưu thành công.
- KB5: Luồng chính + *a --> quản lý chuỗi huỷ yêu cầu, danh sách phim không đổi.

## 9. Activity diagram

File: diagrams/P04-activity-UC-010.drawio

Bảng đối chiếu

| Bước UC | Node |
|---|---|
| 1 | D-1, A-1 |
| 2 | A-2 |
| 3 | M-3, A-3 |
| 4, 4a | A-4, D-4, A-4a |
| 5 | A-5 |
| 6 | A-6, FINAL-1 |
| 1a1, 1a2, 1a3 | A-1a1, A-1a2, A-1a3 |
| *a | N-*a |

Bảng Node

| ID | Loại | Nhãn | Stereotype | Thuộc về (container) | Bước UC | Ghi chú |
|---|---|---|---|---|---|---|
| P-ACT-05 | Partition | Quản lý chuỗi | - | - | - | x=0, w=560 |
| P-SYS | Partition | Hệ thống | - | - | - | x=560, w=541 |
| INIT | Initial | - | - | P-ACT-05 | - | x=130, y=60 (tương đối partition) |
| D-1 | Decision | - | - | P-ACT-05 | 1a | x=130, y=130 (tương đối partition) |
| A-1 | Action | Yêu cầu thêm phim mới | - | P-ACT-05 | 1 | x=60, y=210 (tương đối partition) |
| A-2 | Action | Hiển thị danh sách phim | - | P-SYS | 2 | x=60, y=210 (tương đối partition) |
| M-3 | Merge | - | - | P-ACT-05 | 4a | x=130, y=330 (tương đối partition) |
| A-3 | Action | Nhập thông tin phim và gửi | - | P-ACT-05 | 3 | x=60, y=400 (tương đối partition) |
| A-4 | Action | Kiểm tra thông tin phim hợp lệ | - | P-SYS | 4 | x=60, y=400 (tương đối partition) |
| D-4 | Decision | - | - | P-SYS | 4a | x=130, y=500 (tương đối partition) |
| A-4a | Action | Từ chối: thông tin phim không hợp lệ | - | P-SYS | 4a | x=320, y=490 (tương đối partition) |
| A-5 | Action | Lưu thông tin phim | - | P-SYS | 5 | x=60, y=600 (tương đối partition) |
| A-6 | Action | Thông báo lưu phim thành công | - | P-SYS | 6 | x=60, y=700 (tương đối partition) |
| FINAL-1 | ActivityFinal | - | - | P-SYS | 6 | x=130, y=800 (tương đối partition) |
| A-1a1 | Action | Hiển thị danh sách phim | - | P-SYS | 1a1 | x=60, y=900 (tương đối partition) |
| A-1a2 | Action | Chọn phim cần sửa | - | P-ACT-05 | 1a2 | x=300, y=900 (tương đối partition) |
| A-1a3 | Action | Hiển thị thông tin hiện tại của phim | - | P-SYS | 1a3 | x=60, y=1000 (tương đối partition) |
| N-*a | Note | *a: Tại bất kỳ bước nào trước bước 5, kể cả trong luồng 1a, quản lý chuỗi huỷ yêu cầu: hệ thống không đổi danh sách phim, kết thúc (thất bại) | - | P-ACT-05 | *a | x=300, y=60 (tương đối partition) |

Bảng Edge

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú | Điểm uốn |
|---|---|---|---|---|---|---|
| E-01 | INIT | D-1 | ControlFlow | - | - | - |
| E-02 | D-1 | A-1 | ControlFlow | [thêm phim] | - | - |
| E-03 | D-1 | A-1a1 | ControlFlow | [sửa phim] | - | (290,150); (290,880); (710,880) |
| E-04 | A-1 | A-2 | ControlFlow | - | - | - |
| E-05 | A-2 | M-3 | ControlFlow | - | - | - |
| E-06 | M-3 | A-3 | ControlFlow | - | - | - |
| E-07 | A-3 | A-4 | ControlFlow | - | - | - |
| E-08 | A-4 | D-4 | ControlFlow | - | - | - |
| E-09 | D-4 | A-4a | ControlFlow | [thông tin phim không hợp lệ] | - | - |
| E-10 | D-4 | A-5 | ControlFlow | [khác] | - | - |
| E-11 | A-4a | M-3 | ControlFlow | - | - | (970,470); (250,470); (250,310); (150,310) |
| E-12 | A-5 | A-6 | ControlFlow | - | - | - |
| E-13 | A-6 | FINAL-1 | ControlFlow | - | - | - |
| E-14 | A-1a1 | A-1a2 | ControlFlow | - | - | - |
| E-15 | A-1a2 | A-1a3 | ControlFlow | - | - | - |
| E-16 | A-1a3 | M-3 | ControlFlow | - | - | (850,1030); (850,300); (150,300) |

Ghi chú sơ đồ: D-1 đặt trong partition của quản lý chuỗi, ngay sau INIT, vì quản lý chuỗi chọn thêm hoặc sửa thay cho bước 1 (F5.2). Luồng 1a3 và luồng 4a quay lại merge node M-3 đặt ngay trước A-3, cùng điểm vào với cạnh từ A-2. Luồng *a chỉ thể hiện bằng note N-*a (F10.2). Cạnh nào không ghi điểm uốn thì đường đi do trình vẽ đặt.

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ | Người quyết | Đề xuất |
|---|---|---|---|---|---|
| Q-195 | Quản lý chuỗi có được xoá phim khỏi danh sách phim không? Phim đã từng có suất chiếu (kể cả suất chiếu đã xoá, vé đã bán hoặc đã huỷ, khoản hoàn tiền) thì xử lý thế nào? | Luồng thay thế xoá phim (chưa viết); hậu điều kiện; Mục 8; UC-014, UC-006 | REQ-53 chỉ nêu "quản lý danh sách phim", P00 ghi chưa tách thao tác vì nguồn không phân biệt; BR-58 chỉ nêu giữ dữ liệu của suất chiếu đã xoá | Bên nghiệp vụ | Không có thao tác xoá phim; phim ngừng chiếu bằng cách sửa ngày kết thúc chiếu (REQ-95); danh sách phim chỉ có thêm và sửa |
| Q-196 | Thời lượng phim nhận giá trị nào: số phút nguyên lớn hơn 0, có giá trị tối đa không? | Dữ liệu vào 1 (trường 3), luồng 4a; BR-50 | REQ-07 liệt kê thời lượng, REQ-98 dùng thời lượng tính giờ kết thúc, không nêu miền giá trị | Bên nghiệp vụ | Số nguyên phút lớn hơn 0, không có giá trị tối đa |
| Q-197 | Ngày kết thúc chiếu có được trước ngày khởi chiếu không? | Dữ liệu vào 1 (trường 8, 9), luồng 4a; BR-49, BR-76 | REQ-95 nêu hai ngày, không nêu quan hệ giữa chúng | Bên nghiệp vụ | Ngày kết thúc chiếu không được trước ngày khởi chiếu; hai ngày bằng nhau là hợp lệ (phim chiếu một ngày) |
| Q-198 | Độ tuổi được xem nhận giá trị nào: nhãn phân loại hay số tuổi tối thiểu, và tập giá trị cho phép là gì? | Dữ liệu vào 1 (trường 4), luồng 4a | REQ-07 liệt kê "độ tuổi được xem", không nêu biểu diễn và miền giá trị | Bên nghiệp vụ | Chọn một nhãn phân loại độ tuổi trong tập P, K, T13, T16, T18, C |
| Q-199 | Trailer của phim là dữ liệu gì (đường dẫn tới video đặt ngoài hệ thống hay tệp video tải lên) và có bắt buộc nhập không? | Dữ liệu vào 1 (trường 6), luồng 4a; P13 bảng movie | REQ-07 liệt kê "trailer", không nêu dạng dữ liệu; Q-137 (P13) không nêu trailer | Nhóm dự án | Đường dẫn dạng văn bản tới video đặt ngoài hệ thống, không bắt buộc |
| Q-200 | Hai phim có được trùng tên không? | Dữ liệu vào 1 (trường 1), bước 4, luồng 4a (hoặc luồng 4b mới) | REQ-07 và REQ-53 không nêu điều kiện duy nhất của tên phim | Bên nghiệp vụ | Cho phép trùng tên (hai tác phẩm khác nhau có thể cùng tên); hệ thống phân biệt phim bằng mã phim, không báo trùng |
| Q-201 | Hai yêu cầu cùng sửa một phim (của hai quản lý chuỗi hoặc hai phiên làm việc của cùng một người), hoặc một yêu cầu lưu khi phim đã bị yêu cầu kia sửa kể từ lúc hiển thị: xử lý thế nào? | Bước 5, luồng 1a (thêm luồng 5a); thao tác nguyên tử Lưu phim | Nguồn chỉ nêu xử lý đồng thời cho suất chiếu (Mục 16) và bảng giá (Mục 15), không nêu cho phim | Bên nghiệp vụ | Yêu cầu lưu sau bị từ chối, không ghi đè thay đổi trước, quản lý chuỗi mở lại phim từ đầu (như BR-60, BR-63) |
| Q-202 | Phim bị sửa (UC-010) xen vào giữa lúc UC-014 kiểm tra và tính theo phim (bước 5 đến bước 7: định dạng phát hành, khoảng chiếu, thời lượng) và lúc UC-014 lưu suất chiếu (bước 8): xử lý thế nào? | UC-014 bước 8 và luồng 8e; BR-47, BR-49, BR-50, BR-84; thao tác nguyên tử Lưu phim | REQ-144 chỉ nêu phim đổi sau khi lập suất chiếu, không nêu phim đổi trong lúc đang lập | Bên nghiệp vụ | UC-014 bước 8 kiểm lại BR-47, BR-49 và tính lại giờ kết thúc (BR-50) theo phim hiện hành trong cùng thao tác không chia cắt với việc lưu suất chiếu; ghi nhận trước thì thắng; UC-014 thất bại thì quay lại bước 3 (như BR-68 với bảng giá); phim sửa ghi nhận sau suất chiếu thì không đổi suất chiếu đã lưu (BR-84) |
| Q-203 | Vé ghi tên phim, tên cụm rạp, tên phòng chiếu và loại phòng (REQ-105). Khi UC-010, UC-011, UC-012 sửa các thông tin này sau khi vé đã bán, vé và email hiển thị giá trị lúc bán hay giá trị hiện hành? | Nội dung vé, lịch sử đặt vé, email vé và email hoàn tiền (REQ-116); UC-005, UC-006, UC-007; mục 8 của UC-010, UC-011, UC-012 | REQ-105 nêu nội dung vé, REQ-149 chỉ nêu vé giữ giá; REQ-144 chỉ nêu suất chiếu không tự đổi | Bên nghiệp vụ | Giá trị lúc bán, như giá vé (BR-67): vé đã bán không đổi nội dung khi tên phim, tên cụm rạp, tên phòng, loại phòng đổi sau đó |

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P04 | UC-014 bước 8, Mục 8 | UC-014 chưa nêu UC-010 (lưu phim) là đối thủ của bước 5 đến bước 8, trong khi bước 5 đến bước 7 đọc dữ liệu phim (00-Concurrency.md M1 quy tắc 2) | Ghi UC-010 bước 5 vào cột "Loại trừ với" của thao tác lưu suất chiếu; nội dung xử lý theo Q-202 |
| P08 | EX-13, mục 6 sau F4b | Movie đang ghi "không là đơn vị khoá"; nếu Q-202 theo đề xuất thì EX-13 phải đọc phim trong cùng thao tác | Nếu Q-202 theo đề xuất: thêm Movie (S) vào bộ khoá của EX-13 và một đơn vị loại trừ mới cho lưu phim (UC-010), cùng cặp X với EX-13 |
| P13 | TBL movie | Bảng movie không có cột trailer dù REQ-07 nêu trailer và Q-137 không loại trailer | Thêm cột trailer sau khi Q-199 được trả lời |

## Vấn đề còn mở

- Q-195 đến Q-203 chưa được trả lời. Bước và luồng sẽ thêm hoặc đổi theo từng phương án: Q-195 nếu cho xoá phim thì thêm luồng 1b và đặc tả lại hậu điều kiện; Q-196, Q-197, Q-198, Q-199 điền điều kiện hợp lệ vào Dữ liệu vào 1 và luồng 4a; Q-200 nếu cấm trùng tên thì thêm luồng 4b và BR; Q-201 nếu trả lời theo đề xuất thì thêm luồng 5a (phim đã bị yêu cầu khác sửa, từ chối, không ghi đè, kết thúc thất bại) và BR; Q-202 nếu trả lời theo đề xuất thì UC-014 thêm kiểm tra ở bước 8 và UC-010 thêm BR loại trừ; Q-203 nếu trả lời khác đề xuất thì vé phải hiển thị giá trị hiện hành.
- Hậu điều kiện, thao tác nguyên tử và kết cục bên thua của hai yêu cầu cùng sửa phim chưa viết được vì nguồn không có quy định (NGHIEM_NGAT).
- Luồng chính có 6 bước, trong khoảng 3-15; use case chỉ có thao tác dữ liệu đơn giản nên không tách thêm bước.
- Bố cục activity diagram đã kiểm: không đường nối nào cắt qua node, không node nào chồng nhau.
