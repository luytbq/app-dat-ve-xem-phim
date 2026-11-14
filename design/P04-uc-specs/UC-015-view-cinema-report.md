# P04 - Đặc tả use case UC-015 Xem báo cáo cụm rạp - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P04 |
| Phiên bản | 1.1 |
| Thay đổi 1.1 | Chốt Q-181 đến Q-187: thêm luồng 1a (kỳ báo cáo không hợp lệ), điều kiện của bước 2, 3, 4, kỳ báo cáo ở Dữ liệu vào 1, BR-115 đến BR-119 |
| Đầu vào đã dùng | 00-Conventions.md; 00-Concurrency.md; project-profile.md; yeu-cau-dat-ve.md; P00-problem-brief.md 1.11; P01-actors.md 1.2; P02-usecases.md 1.9; P03-usecase-model.md 1.2; _BR-register.md (đã gộp BR-01 đến BR-147); P05-glossary.md 1.2; P06-supplementary-spec.md 1.4; UC-008-cancel-ticket.md 1.9 (tình trạng hoàn tiền), UC-014-schedule-showtimes.md 1.6 (suất chiếu đã xoá) |
| Phạm vi | UC-015 |
| Mã Q, ASM cuối đã cấp | Q-187 (Q-181 đến Q-184, Q-186, Q-187 cấp ở UC-015, đã trả lời); không có ASM (NGHIEM_NGAT) |

## 1. Thông tin chung

| Thuộc tính | Giá trị |
|---|---|
| Mã use case | UC-015 |
| Tên use case | Xem báo cáo cụm rạp (View Cinema Report) |
| Tác nhân chính | ACT-04 Quản lý cụm rạp |
| Tác nhân phụ | Không có |
| Mô tả ngắn | Use case này mô tả tương tác giữa quản lý cụm rạp và hệ thống khi quản lý cụm rạp muốn nắm doanh thu và tỉ lệ lấp đầy ghế của cụm rạp mình theo ngày, theo phim hoặc theo suất chiếu. Kết quả là quản lý cụm rạp xem được báo cáo của cụm rạp mình trong kỳ báo cáo đã chọn. |
| Sự kiện kích hoạt | Quản lý cụm rạp cần nắm kết quả kinh doanh của cụm (EV-17) |
| Tiền điều kiện | Quản lý cụm rạp đã đăng nhập và đang có phiên làm việc (REQ-102). |
| Hậu điều kiện (thành công) | Dữ liệu của hệ thống không thay đổi.<br>Quản lý cụm rạp đã được hiển thị doanh thu và tỉ lệ lấp đầy của cụm rạp mình theo cách xem và kỳ báo cáo đã chọn.<br>Khi kết thúc ở luồng 2a: quản lý cụm rạp đã được thông báo không có suất chiếu của cụm rạp trong kỳ báo cáo; dữ liệu của hệ thống không thay đổi. |
| Hậu điều kiện tối thiểu | Không có luồng kết thúc thất bại; mọi luồng đều không lưu thay đổi dữ liệu nào. |
| Quan hệ | Không có |
| Điểm mở rộng | Không có |
| REQ | REQ-66, REQ-67, REQ-99 (theo P02); REQ-87 (P02 Mục 5 đã gắn UC-015); REQ-153 (Dữ liệu ra 1, bước 4); REQ-102 (tiền điều kiện; P02 Mục 5 ghi "-"); REQ-100 (tham chiếu, UC-017); REQ-57, REQ-56 (tham chiếu, UC-012; sức chứa, phòng chiếu của cụm rạp); REQ-61 (tham chiếu, UC-014; suất chiếu); REQ-30 (tham chiếu, UC-005; mỗi ghế một vé); REQ-140 (tham chiếu, UC-014; suất chiếu đã xoá); REQ-131 (tham chiếu, UC-008; tình trạng hoàn tiền); REQ-35 (tham chiếu, UC-006; Q-187); REQ-58 (căn cứ phụ của BR dẫn ở Mục 6) |

## 2. Luồng sự kiện chính

| STT | Thực hiện bởi | Hành động |
|---|---|---|
| 1 | Quản lý cụm rạp | Yêu cầu xem báo cáo của cụm rạp mình, chọn cách xem (theo ngày, theo phim hoặc theo suất chiếu) và kỳ báo cáo (xem Dữ liệu vào 1). |
| 2 | Hệ thống | Xác định các suất chiếu của cụm rạp của quản lý cụm rạp thuộc kỳ báo cáo (BR-114): suất chiếu có ngày chiếu nằm trong kỳ báo cáo, kể cả suất chiếu chưa tới giờ bắt đầu (BR-117, Q-184), không kể suất chiếu đã xoá (BR-116, Q-183). |
| 3 | Hệ thống | Tính doanh thu của từng nhóm theo cách xem đã chọn, bằng tiền vé đã bán trừ phần tiền đã hoàn cho khách (BR-77); cả tiền vé và phần đã hoàn xếp vào ngày chiếu của suất chiếu có vé đó (BR-115, Q-182); khoản hoàn toàn bộ của thanh toán đến trễ không được trừ (BR-119, Q-187). |
| 4 | Hệ thống | Tính tỉ lệ lấp đầy của từng nhóm theo cách xem đã chọn, từ số ghế của vé đã bán chưa huỷ và sức chứa của các phòng chiếu, ghế đôi tính một ghế (BR-88, BR-06); sức chứa của mỗi suất chiếu là sức chứa lúc suất chiếu diễn ra (BR-118, Q-186). |
| 5 | Hệ thống | Hiển thị báo cáo gồm doanh thu và tỉ lệ lấp đầy của từng nhóm (xem Dữ liệu ra 1). |

## 3. Luồng sự kiện thay thế và ngoại lệ

| STT | Điều kiện | Thực hiện bởi | Hành động | Quay lại / Kết thúc |
|---|---|---|---|---|
| 1a | Kỳ báo cáo thiếu từ ngày hoặc đến ngày, hoặc từ ngày sau đến ngày (Q-181) | Hệ thống | Từ chối xem báo cáo và thông báo kỳ báo cáo không hợp lệ. | Quay lại bước 1 |
| 2a | Không xác định được suất chiếu nào của cụm rạp thuộc kỳ báo cáo | Hệ thống | Thông báo cụm rạp không có suất chiếu trong kỳ báo cáo. | Kết thúc use case (thành công) |

## 4. Luồng con

Không có

## 5. Dữ liệu vào và dữ liệu ra

Dữ liệu vào 1 (bước 1)

| STT | Trường dữ liệu | Mô tả | Bắt buộc | Điều kiện hợp lệ | Ví dụ |
|---|---|---|---|---|---|
| 1 | Cách xem báo cáo | Cách nhóm báo cáo (REQ-66, REQ-67) | Có | Một trong theo ngày, theo phim, theo suất chiếu | Theo phim |
| 2 | Từ ngày | Ngày đầu của kỳ báo cáo, tính trên khoảng ngày từ ngày đến ngày (BR-88, Q-181) | Có | Ngày chiếu của suất chiếu nằm trong kỳ gồm cả ngày đầu; từ ngày không sau đến ngày | 01/11/2026 |
| 3 | Đến ngày | Ngày cuối của kỳ báo cáo (BR-88, Q-181) | Có | Gồm cả ngày cuối; không trước từ ngày | 30/11/2026 |

Dữ liệu ra 1 (bước 5)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Nhóm báo cáo | Ngày, phim hoặc suất chiếu, theo cách xem đã chọn; mỗi nhóm một dòng | Ngày dạng dd/mm/yyyy; phim là tên phim; suất chiếu gồm tên phim, tên phòng chiếu và ngày giờ bắt đầu dạng dd/mm/yyyy hh:mm | Phim A, Phòng 3, 15/11/2026 19:30 |
| 2 | Doanh thu | Tiền vé đã bán trừ phần tiền đã hoàn cho khách của nhóm (REQ-66, REQ-99) | Số nguyên, phân cách hàng nghìn bằng dấu chấm, kèm "đ", căn phải | 12.450.000 đ |
| 3 | Tỉ lệ lấp đầy | Số ghế của vé đã bán chưa huỷ chia cho sức chứa của nhóm, ghế đôi tính một ghế, không tính ghế đang được giữ (REQ-67, REQ-153) | Phần trăm, căn phải; số chữ số thập phân thuộc thiết kế giao diện | 62,5% |

## 6. Quy tắc nghiệp vụ

| BR | Quy tắc | Loại | Bước áp dụng | REQ | Trong sổ BR |
|---|---|---|---|---|---|
| BR-114 | Quản lý cụm rạp chỉ xem báo cáo của cụm rạp mình. | Ràng buộc | 2, Dữ liệu ra 1 | REQ-66, REQ-67; REQ-100 (phụ) | Mới |
| BR-115 | Doanh thu theo ngày xếp cả tiền vé đã bán và phần tiền đã hoàn của một vé vào ngày chiếu của suất chiếu có vé đó. | Tính toán | 3, Dữ liệu ra 1 | REQ-99; REQ-66 (phụ); Q-182 | Mới |
| BR-116 | Suất chiếu đã xoá không được tính vào tổng sức chứa của tỉ lệ lấp đầy. | Tính toán | 2, 4 | REQ-153; REQ-140 (phụ); Q-183 | Mới |
| BR-117 | Mọi suất chiếu có ngày chiếu trong kỳ báo cáo được tính vào doanh thu và tỉ lệ lấp đầy, kể cả suất chiếu chưa tới giờ bắt đầu, theo dữ liệu tại lúc xem. | Tính toán | 2, 3, 4 | REQ-99, REQ-153; Q-184 | Mới |
| BR-118 | Suất chiếu đã kết thúc hoặc đã xoá giữ sơ đồ ghế, loại ghế và sức chứa lúc suất chiếu mở bán; sửa sơ đồ ghế của phòng chiếu sau đó không đổi vé, sức chứa và tỉ lệ lấp đầy của các suất chiếu đó; suất chiếu chưa mở bán dùng sơ đồ mới. | Ràng buộc | 4 | REQ-153, REQ-58 (phụ); Q-186, Q-210 | Mới |
| BR-119 | Khoản hoàn toàn bộ của giao dịch thanh toán đến trễ (UC-006) không được trừ vào doanh thu, vì giao dịch đó không tạo vé nên chưa nằm trong tiền vé đã bán. | Tính toán | 3 | REQ-99, REQ-35 (phụ); Q-187 | Mới |
| BR-77 | Doanh thu gồm tiền vé đã bán trừ phần tiền đã hoàn cho khách. | Tính toán | 3, Dữ liệu ra 1 | REQ-99 | Đã có |
| BR-88 | Tỉ lệ lấp đầy của một suất chiếu bằng số ghế của vé đã bán chưa huỷ chia cho sức chứa của phòng chiếu; tỉ lệ lấp đầy theo ngày hoặc theo phim bằng tổng số ghế của vé đã bán chưa huỷ chia cho tổng sức chứa của các suất chiếu trong ngày hoặc của phim trong kỳ báo cáo; ghế đang được giữ không được tính. | Tính toán | 4, Dữ liệu ra 1 | REQ-153; REQ-67, REQ-87 (phụ) | Đã có |
| BR-06 | Ghế đôi được tính là một ghế khi đếm số ghế của một lần giữ ghế, sức chứa phòng và tỉ lệ lấp đầy. | Suy luận | 4, Dữ liệu ra 1 | REQ-87 | Đã có |

## 7. Yêu cầu đặc biệt

Không có

## 8. Thông tin bổ sung

- Báo cáo cộng cả vé mua trực tuyến và vé mua tại quầy (cùng là vé của suất chiếu, P05 GL-59, GL-63, GL-64). Suất chiếu của cụm rạp là suất chiếu của các phòng chiếu thuộc cụm rạp (REQ-56, REQ-61).
- Doanh thu theo BR-77: tiền vé đã bán là giá ghi trên vé (BR-67); vé đã huỷ vẫn nằm trong tiền vé đã bán và phần đã hoàn của vé đó được trừ. Chỉ khoản hoàn có tình trạng hoàn tiền là đã hoàn mới được trừ; khoản hoàn chưa hoàn được và đã ghi log lỗi chưa được trừ cho tới khi được xử lý thủ công ngoài hệ thống (UC-008 Mục 8, P05 GL-04, GL-56). Vé mua tại quầy huỷ có tiền mặt hoàn luôn thành công nên luôn được trừ (UC-008 Mục 8).
- Tỉ lệ lấp đầy theo BR-88: vé đã sử dụng vẫn là vé đã bán chưa huỷ; ghế đang được giữ chưa tính vì có thể hết hạn (BR-88 ghi chú). Tử số tính theo số ghế, mỗi vé một ghế (REQ-30), ghế đôi một ghế (BR-06, BR-74).
- Một suất chiếu thuộc kỳ báo cáo khi ngày chiếu của suất nằm trong kỳ, theo cách BR-88 viết "các suất chiếu trong ngày" và "các suất chiếu trong kỳ báo cáo". Suất chiếu chưa tới giờ bắt đầu được tính (BR-117). Suất chiếu đã xoá không được tính vào tổng sức chứa (BR-116); dữ liệu của suất đó vẫn được giữ cho báo cáo (REQ-140, BR-58) nên phần tiền vé của suất đó, nếu có vé đã huỷ, vẫn thuộc doanh thu.
- Báo cáo tính từ dữ liệu có tại thời điểm hệ thống xử lý bước 3 và bước 4; nguồn không nêu việc chốt báo cáo theo ngày.
- Use case do tác nhân người kích hoạt, không có use case nào do tác nhân thời gian kích hoạt dùng dữ liệu của use case này làm mốc, nên không có bước hẹn hoặc huỷ mốc (F4.2 mục 17).
- Không có trao đổi với hệ thống ngoài.
- Bước sinh theo quy tắc của prompt: bước 5 báo kết quả cho quản lý cụm rạp (Target 5a); luồng 2a thông báo kết quả rỗng theo Target 5a và tránh phép chia cho tổng sức chứa bằng 0 của BR-88.
- Tải đồng thời: use case chỉ đọc vé, khoản hoàn và suất chiếu. Các use case ghi cùng dữ liệu (UC-005 bước 12, 13 tạo vé; UC-008 bước 4, 7 huỷ vé và ghi tình trạng hoàn tiền; UC-006 hoàn toàn bộ; UC-014 bước 8, 1b3 lập, sửa, xoá suất chiếu) không bị use case này chặn, và use case này không đòi hỏi bất biến nào cần bảo vệ.

Thao tác nguyên tử:

| Thao tác | Bước | Tài nguyên | Bất biến giữ được | Loại trừ với | Kết cục bên thua | Căn cứ |
|---|---|---|---|---|---|---|
| Đọc vé, khoản hoàn, suất chiếu và sức chứa để tính báo cáo | 2, 3, 4 | Vé, khoản hoàn, suất chiếu của cụm rạp | Không có bất biến cần giữ vì use case chỉ đọc | Không loại trừ với UC-005 bước 12, 13; UC-008 bước 4, 7; UC-006; UC-014 bước 8, 1b3 | Không có bên thua; thay đổi ghi nhận sau lúc đọc hiện ở lần xem sau | REQ-99, REQ-153 |

## 8a. Kịch bản chính

- KB1: Luồng chính --> quản lý cụm rạp xem doanh thu và tỉ lệ lấp đầy của cụm rạp mình theo cách xem và kỳ báo cáo đã chọn.
- KB2: Luồng chính + 2a --> cụm rạp không có suất chiếu trong kỳ báo cáo, quản lý cụm rạp nhận thông báo.

## 9. Activity diagram

File: diagrams/P04-activity-UC-015.drawio

Bảng đối chiếu

| Bước UC | Node |
|---|---|
| 1 | A-1 |
| 2 | A-2, D-2 |
| 1a | N-1a |
| 2a | A-2a, FINAL-1 |
| 3 | A-3 |
| 4 | A-4 |
| 5 | A-5, FINAL-2 |

Bảng Node

| ID | Loại | Nhãn | Stereotype | Thuộc về (container) | Bước UC | Ghi chú |
|---|---|---|---|---|---|---|
| P-ACT-04 | Partition | Quản lý cụm rạp | - | - | - | x=0, w=300 |
| P-SYS | Partition | Hệ thống | - | - | - | x=300, w=520 |
| INIT | Initial | - | - | P-ACT-04 | - | x=130, y=60 (tương đối partition) |
| A-1 | Action | Yêu cầu xem báo cáo, chọn cách xem và kỳ | - | P-ACT-04 | 1 | x=60, y=130 (tương đối partition) |
| N-1a | Note | 1a: Kỳ báo cáo không hợp lệ (thiếu ngày, từ ngày sau đến ngày): từ chối, thông báo, quay lại bước 1 (Q-181) | - | P-SYS | 1a | x=300, y=120, w=200, h=80 (tương đối partition) |
| A-2 | Action | Xác định suất chiếu của cụm rạp trong kỳ | - | P-SYS | 2 | x=60, y=230 (tương đối partition) |
| D-2 | Decision | - | - | P-SYS | 2a | x=130, y=320 (tương đối partition) |
| A-2a | Action | Thông báo không có suất chiếu trong kỳ | - | P-SYS | 2a | x=320, y=310 (tương đối partition) |
| FINAL-1 | ActivityFinal | - | - | P-SYS | - | x=390, y=410 (tương đối partition) |
| A-3 | Action | Tính doanh thu từng nhóm (BR-77) | - | P-SYS | 3 | x=60, y=410 (tương đối partition) |
| A-4 | Action | Tính tỉ lệ lấp đầy từng nhóm (BR-88) | - | P-SYS | 4 | x=60, y=510 (tương đối partition) |
| A-5 | Action | Hiển thị báo cáo | - | P-SYS | 5 | x=60, y=610 (tương đối partition) |
| FINAL-2 | ActivityFinal | - | - | P-SYS | - | x=130, y=710 (tương đối partition) |

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
| E-09 | A-5 | FINAL-2 | ControlFlow | - | - | - |

Hai partition: ACT-04 Quản lý cụm rạp và hệ thống (P-SYS); luồng 2a chỉ có hành động của hệ thống. Guard [khác] của D-2 là trường hợp cụm rạp có ít nhất một suất chiếu được tính vào báo cáo trong kỳ.

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ |
|---|---|---|---|
| Q-181 | Đã trả lời (Theo đề xuất: Khoảng ngày gồm từ ngày và đến ngày, bắt buộc, hai ngày đầu và cuối thuộc kỳ; từ ngày không sau đến ngày). Kỳ báo cáo do quản lý chọn theo hình thức nào: một khoảng ngày (từ ngày, đến ngày), một ngày, hay tháng, tuần? | Dữ liệu vào 1 dòng 2; bước 1, 2; luồng "kỳ báo cáo không hợp lệ" chưa có; UC-016 dùng lại đáp án | Mục 17 nêu báo cáo "theo ngày, theo phim và theo suất chiếu" và công thức dùng "kỳ báo cáo", không nêu quản lý chọn kỳ thế nào |
| Q-182 | Đã trả lời (Theo đề xuất: Ngày chiếu của suất chiếu: cả tiền vé và phần đã hoàn đều xếp vào ngày chiếu của suất chiếu có vé đó (cùng cách BR-88 xếp suất chiếu vào ngày)). Khi xem báo cáo doanh thu theo ngày, doanh thu của một vé thuộc ngày nào: ngày chiếu của suất chiếu, ngày bán vé, hay ngày hoàn tiền của phần đã hoàn? | Bước 3; Dữ liệu ra 1 | Mục 17 nêu "doanh thu gồm tiền vé đã bán trừ phần tiền đã hoàn" và "theo ngày", không nêu mốc ngày của tiền bán và tiền hoàn |
| Q-183 | Đã trả lời (Theo đề xuất: Không tính vì suất chiếu đã bị bỏ khỏi lịch chiếu và ngừng bán vé). Suất chiếu đã xoá (đã bỏ khỏi lịch chiếu, BR-58) có được tính vào tổng sức chứa của tỉ lệ lấp đầy không? | Bước 2, 4 | Mục 17 nêu tổng sức chứa "của các suất chiếu trong kỳ báo cáo"; Mục 16 nêu xoá suất chiếu là bỏ khỏi lịch chiếu nhưng giữ dữ liệu cho báo cáo |
| Q-184 | Đã trả lời (Theo đề xuất: Có tính mọi suất chiếu có ngày chiếu trong kỳ, kể cả chưa diễn ra, theo dữ liệu tại lúc xem). Suất chiếu chưa tới giờ bắt đầu trong kỳ báo cáo có được tính vào doanh thu và tỉ lệ lấp đầy không? | Bước 2, 3, 4 | Mục 17 nêu "các suất chiếu trong kỳ báo cáo", không nêu suất chưa diễn ra |
| Q-186 | Đã trả lời (Theo đề xuất: Sức chứa lúc suất chiếu diễn ra, lưu cùng suất chiếu, để báo cáo của kỳ cũ không đổi khi phòng chiếu đổi sơ đồ ghế). Sức chứa dùng cho suất chiếu đã kết thúc khi phòng chiếu sau đó được sửa sơ đồ ghế là sức chứa hiện tại của phòng hay sức chứa lúc suất chiếu diễn ra? | Bước 4 | Mục 15 cho sửa sơ đồ ghế của phòng khi không có suất chiếu đã mở bán mà chưa kết thúc; Mục 17 dùng "sức chứa của phòng chiếu" không nêu thời điểm |
| Q-187 | Đã trả lời (Theo đề xuất: Không trừ vì giao dịch đó không tạo vé nên chưa nằm trong tiền vé đã bán). Khoản hoàn toàn bộ của thanh toán đến trễ (UC-006) có được trừ vào doanh thu không? | Bước 3 | Mục 17 nêu "trừ phần tiền đã hoàn cho khách"; Mục 9 nêu hoàn toàn bộ cho giao dịch không tạo vé |

## Giả định

Không áp dụng (CHE_DO_GIA_DINH là NGHIEM_NGAT).

## Đề xuất sửa artifact trước

Không có

## Vấn đề còn mở

- Luồng chính có 5 bước, trong khoảng 3-15.
- Kiểm công thức: tỉ lệ lấp đầy của một suất chiếu có sức chứa 50 ghế và 30 vé đã bán chưa huỷ (mỗi vé một ghế, ghế đôi tính một ghế) bằng 30 / 50 = 60%; doanh thu của vé giá 100.000 đ đã huỷ và hoàn 70% (70.000 đ) bằng 100.000 - 70.000 = 30.000 đ (BR-19, BR-77).
