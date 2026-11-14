# P04 - Đặc tả use case UC-016 Xem báo cáo toàn chuỗi - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P04 |
| Phiên bản | 1.1 |
| Thay đổi 1.1 | Chốt Q-185 và các đáp án Q-181 đến Q-184, Q-186, Q-187 của UC-015: thêm luồng 1a, điều kiện bước 2 đến 5, kỳ báo cáo và kết quả so sánh ở Dữ liệu vào, Dữ liệu ra, BR-115 đến BR-119 |
| Đầu vào đã dùng | 00-Conventions.md; 00-Concurrency.md; project-profile.md; yeu-cau-dat-ve.md; P00-problem-brief.md 1.11; P01-actors.md 1.2; P02-usecases.md 1.9; P03-usecase-model.md 1.2; _BR-register.md (đã gộp BR-01 đến BR-147); P05-glossary.md 1.2; P06-supplementary-spec.md 1.4; UC-008-cancel-ticket.md 1.9 (tình trạng hoàn tiền), UC-014-schedule-showtimes.md 1.6 (suất chiếu đã xoá) |
| Phạm vi | UC-016 |
| Mã Q, ASM cuối đã cấp | Q-185 (cấp ở UC-016, đã trả lời); không có ASM (NGHIEM_NGAT) |

## 1. Thông tin chung

| Thuộc tính | Giá trị |
|---|---|
| Mã use case | UC-016 |
| Tên use case | Xem báo cáo toàn chuỗi (View Chain Report) |
| Tác nhân chính | ACT-05 Quản lý chuỗi |
| Tác nhân phụ | Không có |
| Mô tả ngắn | Use case này mô tả tương tác giữa quản lý chuỗi và hệ thống khi quản lý chuỗi muốn nắm doanh thu và tỉ lệ lấp đầy ghế của toàn chuỗi và so sánh kết quả giữa các cụm rạp. Kết quả là quản lý chuỗi xem được báo cáo toàn chuỗi cùng kết quả so sánh giữa các cụm rạp trong kỳ báo cáo đã chọn. |
| Sự kiện kích hoạt | Quản lý chuỗi cần nắm và so sánh kết quả các cụm rạp (EV-18) |
| Tiền điều kiện | Quản lý chuỗi đã đăng nhập và đang có phiên làm việc (REQ-102). |
| Hậu điều kiện (thành công) | Dữ liệu của hệ thống không thay đổi.<br>Quản lý chuỗi đã được hiển thị doanh thu và tỉ lệ lấp đầy của toàn chuỗi cùng kết quả so sánh giữa các cụm rạp theo cách xem và kỳ báo cáo đã chọn.<br>Khi kết thúc ở luồng 2a: quản lý chuỗi đã được thông báo không có suất chiếu của chuỗi trong kỳ báo cáo; dữ liệu của hệ thống không thay đổi. |
| Hậu điều kiện tối thiểu | Không có luồng kết thúc thất bại; mọi luồng đều không lưu thay đổi dữ liệu nào. |
| Quan hệ | Không có |
| Điểm mở rộng | Không có |
| REQ | REQ-68, REQ-69, REQ-99 (theo P02); REQ-87 (P02 Mục 5 đã gắn UC-016); REQ-153 (bước 4, Dữ liệu ra 1); REQ-102 (tiền điều kiện; P02 Mục 5 ghi "-"); REQ-100 (tham chiếu, UC-017); REQ-66, REQ-67 (tham chiếu, UC-015; cách xem theo ngày, theo phim, theo suất chiếu); REQ-57 (tham chiếu, UC-012; sức chứa); REQ-140 (tham chiếu, UC-014; suất chiếu đã xoá); REQ-131 (tham chiếu, UC-008; tình trạng hoàn tiền); REQ-35 (tham chiếu, UC-006; Q-187) |

## 2. Luồng sự kiện chính

| STT | Thực hiện bởi | Hành động |
|---|---|---|
| 1 | Quản lý chuỗi | Yêu cầu xem báo cáo của toàn chuỗi, chọn cách xem (theo ngày, theo phim hoặc theo suất chiếu) và kỳ báo cáo (xem Dữ liệu vào 1). |
| 2 | Hệ thống | Xác định các suất chiếu của mọi cụm rạp thuộc kỳ báo cáo : suất chiếu có ngày chiếu nằm trong kỳ báo cáo, kể cả suất chiếu chưa tới giờ bắt đầu (BR-117), không kể suất chiếu đã xoá (BR-116). |
| 3 | Hệ thống | Tính doanh thu của toàn chuỗi và của từng cụm rạp theo cách xem đã chọn, bằng tiền vé đã bán trừ phần tiền đã hoàn cho khách (BR-77); cả tiền vé và phần đã hoàn xếp vào ngày chiếu của suất chiếu có vé đó (BR-115); khoản hoàn toàn bộ của thanh toán đến trễ không được trừ (BR-119). |
| 4 | Hệ thống | Tính tỉ lệ lấp đầy của toàn chuỗi và của từng cụm rạp theo cách xem đã chọn, từ số ghế của vé đã bán chưa huỷ và sức chứa của các phòng chiếu, ghế đôi tính một ghế (BR-88, BR-06); sức chứa của mỗi suất chiếu là sức chứa lúc suất chiếu diễn ra (BR-118). |
| 5 | Hệ thống | Tổng hợp doanh thu và tỉ lệ lấp đầy của các cụm rạp để so sánh giữa các cụm rạp bằng cách đặt doanh thu và tỉ lệ lấp đầy của mọi cụm rạp cạnh nhau trong cùng kỳ báo cáo và cùng cách xem; không tính chênh lệch, không xếp hạng, không chọn tập con cụm rạp (Q-185). |
| 6 | Hệ thống | Hiển thị báo cáo toàn chuỗi cùng kết quả so sánh giữa các cụm rạp (xem Dữ liệu ra 1, Dữ liệu ra 2). |

## 3. Luồng sự kiện thay thế và ngoại lệ

| STT | Điều kiện | Thực hiện bởi | Hành động | Quay lại / Kết thúc |
|---|---|---|---|---|
| 1a | Kỳ báo cáo thiếu từ ngày hoặc đến ngày, hoặc từ ngày sau đến ngày (Q-181) | Hệ thống | Từ chối xem báo cáo và thông báo kỳ báo cáo không hợp lệ. | Quay lại bước 1 |
| 2a | Không xác định được suất chiếu nào của chuỗi thuộc kỳ báo cáo | Hệ thống | Thông báo chuỗi không có suất chiếu trong kỳ báo cáo. | Kết thúc use case (thành công) |

## 4. Luồng con

Không có

## 5. Dữ liệu vào và dữ liệu ra

Dữ liệu vào 1 (bước 1)

| STT | Trường dữ liệu | Mô tả | Bắt buộc | Điều kiện hợp lệ | Ví dụ |
|---|---|---|---|---|---|
| 1 | Cách xem báo cáo | Cách nhóm báo cáo (REQ-66, REQ-67, REQ-68) | Có | Một trong theo ngày, theo phim, theo suất chiếu | Theo ngày |
| 2 | Từ ngày | Ngày đầu của kỳ báo cáo, tính trên khoảng ngày từ ngày đến ngày (BR-88, Q-181) | Có | Ngày chiếu của suất chiếu nằm trong kỳ gồm cả ngày đầu; từ ngày không sau đến ngày | 01/11/2026 |
| 3 | Đến ngày | Ngày cuối của kỳ báo cáo (BR-88, Q-181) | Có | Gồm cả ngày cuối; không trước từ ngày | 30/11/2026 |

Dữ liệu ra 1 (bước 6)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Nhóm báo cáo | Ngày, phim hoặc suất chiếu, theo cách xem đã chọn; mỗi nhóm một dòng | Ngày dạng dd/mm/yyyy; phim là tên phim; suất chiếu gồm tên phim, tên cụm rạp, tên phòng chiếu và ngày giờ bắt đầu dạng dd/mm/yyyy hh:mm | 15/11/2026 |
| 2 | Doanh thu toàn chuỗi | Tiền vé đã bán trừ phần tiền đã hoàn cho khách, của nhóm, trên mọi cụm rạp (REQ-68, REQ-99) | Số nguyên, phân cách hàng nghìn bằng dấu chấm, kèm "đ", căn phải | 185.300.000 đ |
| 3 | Tỉ lệ lấp đầy toàn chuỗi | Số ghế của vé đã bán chưa huỷ chia cho sức chứa của nhóm trên mọi cụm rạp, ghế đôi tính một ghế, không tính ghế đang được giữ (REQ-68, REQ-153) | Phần trăm, căn phải; số chữ số thập phân thuộc thiết kế giao diện | 58,2% |

Dữ liệu ra 2 (bước 6)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Tên cụm rạp | Cụm rạp của dòng so sánh (REQ-69) | Văn bản | Cụm rạp X |
| 2 | Doanh thu của cụm rạp | Doanh thu của nhóm tại cụm rạp, cùng cách tính với Dữ liệu ra 1 dòng 2 (REQ-69) | Như Dữ liệu ra 1 dòng 2 | 14.700.000 đ |
| 3 | Tỉ lệ lấp đầy của cụm rạp | Tỉ lệ lấp đầy của nhóm tại cụm rạp, cùng cách tính với Dữ liệu ra 1 dòng 3 (REQ-69) | Như Dữ liệu ra 1 dòng 3 | 64,0% |


## 6. Quy tắc nghiệp vụ

| BR | Quy tắc | Loại | Bước áp dụng | REQ | Trong sổ BR |
|---|---|---|---|---|---|
| BR-115 | Doanh thu theo ngày xếp cả tiền vé đã bán và phần tiền đã hoàn của một vé vào ngày chiếu của suất chiếu có vé đó. | Tính toán | 3, Dữ liệu ra 1, Dữ liệu ra 2 | REQ-99 | Đã có |
| BR-116 | Suất chiếu đã xoá không được tính vào tổng sức chứa của tỉ lệ lấp đầy. | Tính toán | 2, 4 | REQ-153 | Đã có |
| BR-117 | Mọi suất chiếu có ngày chiếu trong kỳ báo cáo được tính vào doanh thu và tỉ lệ lấp đầy, kể cả suất chiếu chưa tới giờ bắt đầu, theo dữ liệu tại lúc xem. | Tính toán | 2, 3, 4 | REQ-99, REQ-153 | Đã có |
| BR-118 | Suất chiếu đã kết thúc hoặc đã xoá giữ sơ đồ ghế, loại ghế và sức chứa lúc suất chiếu mở bán; sửa sơ đồ ghế của phòng chiếu sau đó không đổi vé, sức chứa và tỉ lệ lấp đầy của các suất chiếu đó; suất chiếu chưa mở bán dùng sơ đồ mới. | Ràng buộc | 4 | REQ-153 | Đã có |
| BR-119 | Khoản hoàn toàn bộ của giao dịch thanh toán đến trễ (UC-006) không được trừ vào doanh thu, vì giao dịch đó không tạo vé nên chưa nằm trong tiền vé đã bán. | Tính toán | 3 | REQ-99 | Đã có |
| BR-77 | Doanh thu gồm tiền vé đã bán trừ phần tiền đã hoàn cho khách. | Tính toán | 3, Dữ liệu ra 1, Dữ liệu ra 2 | REQ-99 | Đã có |
| BR-88 | Tỉ lệ lấp đầy của một suất chiếu bằng số ghế của vé đã bán chưa huỷ chia cho sức chứa của phòng chiếu; tỉ lệ lấp đầy theo ngày hoặc theo phim bằng tổng số ghế của vé đã bán chưa huỷ chia cho tổng sức chứa của các suất chiếu trong ngày hoặc của phim trong kỳ báo cáo; ghế đang được giữ không được tính. | Tính toán | 4, Dữ liệu ra 1, Dữ liệu ra 2 | REQ-153; REQ-68, REQ-87 (phụ) | Đã có |
| BR-06 | Ghế đôi được tính là một ghế khi đếm số ghế của một lần giữ ghế, sức chứa phòng và tỉ lệ lấp đầy. | Suy luận | 4, Dữ liệu ra 1, Dữ liệu ra 2 | REQ-87 | Đã có |

## 7. Yêu cầu đặc biệt

Không có

## 8. Thông tin bổ sung

- Quản lý chuỗi không thuộc cụm rạp nào (REQ-100, BR-78) nên báo cáo không bị giới hạn theo cụm rạp; BR-114 (quản lý cụm rạp chỉ xem cụm mình) chỉ áp dụng cho UC-015.
- Báo cáo toàn chuỗi dùng cùng cách tính doanh thu và tỉ lệ lấp đầy như UC-015 (BR-77, BR-88, BR-06), mở rộng ra mọi cụm rạp; các điều kiện về kỳ báo cáo, suất chiếu đã xoá, suất chiếu chưa diễn ra, ngày xếp doanh thu, sức chứa lúc suất chiếu diễn ra và khoản hoàn toàn bộ của thanh toán đến trễ dùng đáp án của Q-181 đến Q-184, Q-186, Q-187 (BR-115 đến BR-119) đã hỏi ở UC-015, không hỏi lại. Các nhận xét về doanh thu, tỉ lệ lấp đầy, vé mua trực tuyến và tại quầy, tình trạng hoàn tiền ở Mục 8 của UC-015 áp dụng như nhau.
- Tỉ lệ lấp đầy của toàn chuỗi theo BR-88 là tổng số ghế của vé đã bán chưa huỷ chia cho tổng sức chứa của các suất chiếu thuộc nhóm trên mọi cụm rạp, không phải trung bình cộng các tỉ lệ của từng cụm rạp.
- Hình thức so sánh giữa các cụm rạp (REQ-69) chỉ có đủ nghĩa khi cùng kỳ báo cáo và cùng cách xem cho mọi cụm rạp; bước 5 so sánh trong cùng kỳ và cùng cách xem đã chọn ở bước 1. Các cụm rạp chỉ được đặt cạnh nhau, không có chênh lệch, thứ hạng hay lựa chọn tập con cụm rạp (Q-185).
- Use case do tác nhân người kích hoạt, không có use case nào do tác nhân thời gian kích hoạt dùng dữ liệu của use case này làm mốc, nên không có bước hẹn hoặc huỷ mốc (F4.2 mục 17).
- Không có trao đổi với hệ thống ngoài.
- Bước sinh theo quy tắc của prompt: bước 6 báo kết quả cho quản lý chuỗi (Target 5a); luồng 2a thông báo kết quả rỗng theo Target 5a và tránh phép chia cho tổng sức chứa bằng 0 của BR-88.
- Tải đồng thời: use case chỉ đọc vé, khoản hoàn và suất chiếu của mọi cụm rạp, cùng đối thủ ghi như UC-015 (UC-005 bước 12, 13; UC-008 bước 4, 7; UC-006; UC-014 bước 8, 1b3), không đòi hỏi bất biến nào cần bảo vệ.

Thao tác nguyên tử:

| Thao tác | Bước | Tài nguyên | Bất biến giữ được | Loại trừ với | Kết cục bên thua | Căn cứ |
|---|---|---|---|---|---|---|
| Đọc vé, khoản hoàn, suất chiếu và sức chứa của mọi cụm rạp để tính báo cáo | 2, 3, 4, 5 | Vé, khoản hoàn, suất chiếu của chuỗi | Không có bất biến cần giữ vì use case chỉ đọc | Không loại trừ với UC-005 bước 12, 13; UC-008 bước 4, 7; UC-006; UC-014 bước 8, 1b3 | Không có bên thua; thay đổi ghi nhận sau lúc đọc hiện ở lần xem sau | REQ-99, REQ-153 |

## 8a. Kịch bản chính

- KB1: Luồng chính --> quản lý chuỗi xem doanh thu, tỉ lệ lấp đầy của toàn chuỗi và so sánh giữa các cụm rạp theo cách xem và kỳ báo cáo đã chọn.
- KB2: Luồng chính + 2a --> chuỗi không có suất chiếu trong kỳ báo cáo, quản lý chuỗi nhận thông báo.

## 9. Activity diagram

File: diagrams/P04-activity-UC-016.drawio

Bảng đối chiếu

| Bước UC | Node |
|---|---|
| 1 | A-1 |
| 2 | A-2, D-2 |
| 1a | N-1a |
| 2a | A-2a, FINAL-1 |
| 3 | A-3 |
| 4 | A-4 |
| 5 | A-5 |
| 6 | A-6, FINAL-2 |

Bảng Node

| ID | Loại | Nhãn | Stereotype | Thuộc về (container) | Bước UC | Ghi chú |
|---|---|---|---|---|---|---|
| P-ACT-05 | Partition | Quản lý chuỗi | - | - | - | x=0, w=300 |
| P-SYS | Partition | Hệ thống | - | - | - | x=300, w=520 |
| INIT | Initial | - | - | P-ACT-05 | - | x=130, y=60 (tương đối partition) |
| A-1 | Action | Yêu cầu xem báo cáo, chọn cách xem và kỳ | - | P-ACT-05 | 1 | x=60, y=130 (tương đối partition) |
| N-1a | Note | 1a: Kỳ báo cáo không hợp lệ (thiếu ngày, từ ngày sau đến ngày): từ chối, thông báo, quay lại bước 1 (Q-181) | - | P-SYS | 1a | x=300, y=120, w=200, h=80 (tương đối partition) |
| A-2 | Action | Xác định suất chiếu của chuỗi trong kỳ | - | P-SYS | 2 | x=60, y=230 (tương đối partition) |
| D-2 | Decision | - | - | P-SYS | 2a | x=130, y=320 (tương đối partition) |
| A-2a | Action | Thông báo không có suất chiếu trong kỳ | - | P-SYS | 2a | x=320, y=310 (tương đối partition) |
| FINAL-1 | ActivityFinal | - | - | P-SYS | - | x=390, y=410 (tương đối partition) |
| A-3 | Action | Tính doanh thu toàn chuỗi và từng cụm (BR-77) | - | P-SYS | 3 | x=60, y=410 (tương đối partition) |
| A-4 | Action | Tính tỉ lệ lấp đầy toàn chuỗi và từng cụm (BR-88) | - | P-SYS | 4 | x=60, y=510 (tương đối partition) |
| A-5 | Action | Tổng hợp kết quả để so sánh các cụm rạp | - | P-SYS | 5 | x=60, y=610 (tương đối partition) |
| A-6 | Action | Hiển thị báo cáo và kết quả so sánh | - | P-SYS | 6 | x=60, y=710 (tương đối partition) |
| FINAL-2 | ActivityFinal | - | - | P-SYS | - | x=130, y=810 (tương đối partition) |

Bảng Edge

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú | Điểm uốn |
|---|---|---|---|---|---|---|
| E-01 | INIT | A-1 | ControlFlow | - | - | - |
| E-02 | A-1 | A-2 | ControlFlow | - | - | (150,260) |
| E-03 | A-2 | D-2 | ControlFlow | - | - | - |
| E-04 | D-2 | A-2a | ControlFlow | [không có suất chiếu] | - | - |
| E-05 | D-2 | A-3 | ControlFlow | [khác] | - | - |
| E-06 | A-2a | FINAL-1 | ControlFlow | - | - | - |
| E-07 | A-3 | A-4 | ControlFlow | - | - | - |
| E-08 | A-4 | A-5 | ControlFlow | - | - | - |
| E-09 | A-5 | A-6 | ControlFlow | - | - | - |
| E-10 | A-6 | FINAL-2 | ControlFlow | - | - | - |

Hai partition: ACT-05 Quản lý chuỗi và hệ thống (P-SYS); luồng 2a chỉ có hành động của hệ thống. Guard [khác] của D-2 là trường hợp chuỗi có ít nhất một suất chiếu được tính vào báo cáo trong kỳ.

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ |
|---|---|---|---|
| Q-185 | Đã trả lời (Theo đề xuất: Đặt doanh thu và tỉ lệ lấp đầy của mọi cụm rạp cạnh nhau trong cùng kỳ báo cáo và cùng cách xem; không tính chênh lệch, không xếp hạng, không chọn tập con cụm rạp). So sánh báo cáo giữa các cụm rạp gồm những gì: chỉ đặt doanh thu và tỉ lệ lấp đầy của các cụm rạp cạnh nhau, hay còn tính chênh lệch, xếp hạng hoặc cho chọn một số cụm rạp để so sánh? | Bước 5, 6; Dữ liệu ra 2 dòng 4 | Mục 17 nêu "Quản lý chuỗi xem các báo cáo này cho toàn chuỗi và so sánh giữa các cụm rạp", không nêu cách so sánh |

## Giả định

Không áp dụng (CHE_DO_GIA_DINH là NGHIEM_NGAT).

## Đề xuất sửa artifact trước

Không có

## Vấn đề còn mở

- Luồng chính có 6 bước, trong khoảng 3-15.
