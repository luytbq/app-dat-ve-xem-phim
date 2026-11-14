# P04 - Đặc tả use case UC-003 Tra cứu phim - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P04 |
| Phiên bản | 1.1 |
| Thay đổi 1.1 | Chốt Q-175 (trường của danh sách phim ở Dữ liệu ra 1); bỏ các đề xuất sửa artifact trước đã được đồng bộ |
| Đầu vào đã dùng | 00-Conventions.md; 00-Concurrency.md; project-profile.md; yeu-cau-dat-ve.md; P00-problem-brief.md 1.11; P01-actors.md 1.2; P02-usecases.md 1.9; P03-usecase-model.md 1.2; _BR-register.md (đã gộp BR-01 đến BR-147); P05-glossary.md 1.2; P06-supplementary-spec.md 1.4 |
| Phạm vi | UC-003 |
| Mã Q, ASM cuối đã cấp | Q-175 (cấp ở UC-003, đã trả lời); không có ASM (NGHIEM_NGAT) |

## 1. Thông tin chung

| Thuộc tính | Giá trị |
|---|---|
| Mã use case | UC-003 |
| Tên use case | Tra cứu phim (Browse Movies) |
| Tác nhân chính | ACT-01 Khách |
| Tác nhân phụ | Không có |
| Mô tả ngắn | Use case này mô tả tương tác giữa khách và hệ thống khi khách muốn biết các phim đang chiếu, sắp chiếu và thông tin của một phim quan tâm. Kết quả là khách nắm được thông tin của phim đã chọn mà không cần đăng nhập. |
| Sự kiện kích hoạt | Khách muốn biết phim đang chiếu, sắp chiếu (EV-03) |
| Tiền điều kiện | Không có (khách không cần đăng nhập, REQ-05, REQ-06). |
| Hậu điều kiện (thành công) | Dữ liệu của hệ thống không thay đổi.<br>Khách đã được hiển thị thông tin của phim đã chọn.<br>Khi kết thúc ở luồng 2a: khách đã được thông báo không có phim đang chiếu hoặc sắp chiếu; dữ liệu của hệ thống không thay đổi. |
| Hậu điều kiện tối thiểu | Không có luồng kết thúc thất bại; mọi luồng đều không lưu thay đổi dữ liệu nào. |
| Quan hệ | Không có |
| Điểm mở rộng | Không có |
| REQ | REQ-05, REQ-06, REQ-07, REQ-96 (theo P02); REQ-95, REQ-53 (tham chiếu, UC-010) |

## 2. Luồng sự kiện chính

| STT | Thực hiện bởi | Hành động |
|---|---|---|
| 1 | Khách | Yêu cầu xem danh sách phim. |
| 2 | Hệ thống | Xác định các phim đang chiếu và các phim sắp chiếu theo ngày hiện tại, ngày khởi chiếu và ngày kết thúc chiếu của từng phim (BR-76). |
| 3 | Hệ thống | Hiển thị danh sách phim đang chiếu và danh sách phim sắp chiếu (xem Dữ liệu ra 1). |
| 4 | Khách | Chọn một phim trong danh sách. |
| 5 | Hệ thống | Hiển thị thông tin của phim đã chọn (xem Dữ liệu ra 2). |

## 3. Luồng sự kiện thay thế và ngoại lệ

| STT | Điều kiện | Thực hiện bởi | Hành động | Quay lại / Kết thúc |
|---|---|---|---|---|
| 2a | Không có phim nào đang chiếu hoặc sắp chiếu (BR-76) | Hệ thống | Thông báo hiện chưa có phim đang chiếu hoặc sắp chiếu. | Kết thúc use case (thành công) |

## 4. Luồng con

Không có

## 5. Dữ liệu vào và dữ liệu ra

Dữ liệu vào: Không có (bước 4 chỉ chọn một phim trong danh sách đã hiển thị ở bước 3).

Dữ liệu ra 1 (bước 3)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Nhóm phim | Phim đang chiếu hoặc phim sắp chiếu (REQ-05, REQ-96) | Văn bản; mỗi phim thuộc đúng một nhóm; nhóm không có phim nào thì không có dòng phim | Đang chiếu |
| 2 | Tên phim | Tên của phim (REQ-07) | Văn bản | Phim A |
| 3 | Thể loại | Thể loại của phim (REQ-07, Q-175) | Văn bản | Hành động |
| 4 | Thời lượng | Thời lượng của phim, đơn vị phút (REQ-07, Q-175) | Số nguyên kèm đơn vị "phút" | 125 phút |
| 5 | Độ tuổi được xem | Độ tuổi được xem phim (REQ-07, Q-175) | Văn bản | Từ 13 tuổi |
| 6 | Ngày khởi chiếu | Ngày khởi chiếu của phim; chỉ hiển thị cho phim sắp chiếu (REQ-95, Q-175) | Ngày dạng dd/mm/yyyy | 20/11/2026 |

Dữ liệu ra 2 (bước 5)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Tên | Tên của phim (REQ-07) | Văn bản | Phim A |
| 2 | Thể loại | Thể loại của phim (REQ-07) | Văn bản | Hành động |
| 3 | Thời lượng | Thời lượng của phim, đơn vị phút (REQ-07; P05 GL-37) | Số nguyên kèm đơn vị "phút" | 125 phút |
| 4 | Độ tuổi được xem | Độ tuổi được xem phim (REQ-07) | Văn bản | Từ 13 tuổi |
| 5 | Mô tả | Mô tả nội dung phim (REQ-07) | Văn bản | Một đội đặc nhiệm phải ngăn chặn một cuộc tấn công. |
| 6 | Trailer | Trailer của phim (REQ-07) | Nội dung xem được qua hệ thống | Trailer của Phim A |

## 6. Quy tắc nghiệp vụ

| BR | Quy tắc | Loại | Bước áp dụng | REQ | Trong sổ BR |
|---|---|---|---|---|---|
| BR-76 | Phim sắp chiếu là phim chưa tới ngày khởi chiếu; phim đang chiếu là phim đã tới ngày khởi chiếu và chưa qua ngày kết thúc chiếu. | Suy luận | 2, 2a, Dữ liệu ra 1 | REQ-96; REQ-95 (phụ) | Đã có |

## 7. Yêu cầu đặc biệt

Không có

## 8. Thông tin bổ sung

- Việc phân nhóm phim chạy ở bước 2 theo ngày hiện tại của hệ thống tại thời điểm khách yêu cầu. Phim có ngày kết thúc chiếu là ngày hiện tại vẫn đang chiếu (hai ngày đầu và cuối thuộc khoảng chiếu, như ghi chú của BR-49 ở UC-014). Phim đã qua ngày kết thúc chiếu không thuộc nhóm nào nên không có trong danh sách (suy ra trực tiếp từ BR-76).
- Danh sách phim của chuỗi do UC-010 quản lý (REQ-53, REQ-95); use case này chỉ đọc, không đổi dữ liệu phim.
- Danh sách ở Dữ liệu ra 1 chỉ có tên, thể loại, thời lượng, độ tuổi được xem và (với phim sắp chiếu) ngày khởi chiếu; mô tả và trailer chỉ hiển thị khi khách chọn một phim (Q-175).
- Thông tin phim ở Dữ liệu ra 2 gồm đúng sáu thành phần của REQ-07. Cách trailer được xem (nhúng trong trang hay mở bằng liên kết) là cách trình bày thuộc thiết kế giao diện, không phải quy tắc nghiệp vụ.
- Nguồn không nêu việc khách chuyển từ thông tin phim sang lịch chiếu của phim; UC-004 tự bắt đầu bằng việc chọn phim hoặc cụm rạp.
- Use case do tác nhân người kích hoạt, không có use case nào do tác nhân thời gian kích hoạt dùng dữ liệu của use case này làm mốc, nên không có bước hẹn hoặc huỷ mốc (F4.2 mục 17).
- Không có trao đổi với hệ thống ngoài (HE_THONG_NGOAI không tham gia).
- Bước sinh theo quy tắc của prompt: bước 3 và bước 5 báo kết quả cho khách (Target 5a); luồng 2a thông báo kết quả rỗng theo Target 5a.
- Tải đồng thời: use case chỉ đọc danh sách phim, không đọc hoặc ghi ghế, giao dịch thanh toán, yêu cầu hoàn tiền. Quản lý chuỗi sửa phim (UC-010) trong lúc khách xem chỉ làm các lần đọc sau thấy dữ liệu mới, không vi phạm quy tắc nào.

Thao tác nguyên tử: Không có

## 8a. Kịch bản chính

- KB1: Luồng chính --> khách xem danh sách phim rồi xem thông tin một phim.
- KB2: Luồng chính + 2a --> không có phim đang chiếu hoặc sắp chiếu, khách nhận thông báo.

## 9. Activity diagram

File: diagrams/P04-activity-UC-003.drawio

Bảng đối chiếu

| Bước UC | Node |
|---|---|
| 1 | A-1 |
| 2 | A-2, D-2 |
| 2a | A-2a, FINAL-1 |
| 3 | A-3 |
| 4 | A-4 |
| 5 | A-5, FINAL-2 |

Bảng Node

| ID | Loại | Nhãn | Stereotype | Thuộc về (container) | Bước UC | Ghi chú |
|---|---|---|---|---|---|---|
| P-ACT-01 | Partition | Khách | - | - | - | x=0, w=300 |
| P-SYS | Partition | Hệ thống | - | - | - | x=300, w=520 |
| INIT | Initial | - | - | P-ACT-01 | - | x=130, y=60 (tương đối partition) |
| A-1 | Action | Yêu cầu xem danh sách phim | - | P-ACT-01 | 1 | x=60, y=130 (tương đối partition) |
| A-2 | Action | Xác định phim đang chiếu, sắp chiếu | - | P-SYS | 2 | x=60, y=230 (tương đối partition) |
| D-2 | Decision | - | - | P-SYS | 2a | x=130, y=320 (tương đối partition) |
| A-2a | Action | Thông báo không có phim | - | P-SYS | 2a | x=320, y=310 (tương đối partition) |
| FINAL-1 | ActivityFinal | - | - | P-SYS | - | x=390, y=410 (tương đối partition) |
| A-3 | Action | Hiển thị danh sách phim | - | P-SYS | 3 | x=60, y=410 (tương đối partition) |
| A-4 | Action | Chọn một phim | - | P-ACT-01 | 4 | x=60, y=510 (tương đối partition) |
| A-5 | Action | Hiển thị thông tin phim | - | P-SYS | 5 | x=60, y=610 (tương đối partition) |
| FINAL-2 | ActivityFinal | - | - | P-SYS | - | x=130, y=710 (tương đối partition) |

Bảng Edge

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú | Điểm uốn |
|---|---|---|---|---|---|---|
| E-01 | INIT | A-1 | ControlFlow | - | - | - |
| E-02 | A-1 | A-2 | ControlFlow | - | - | (150,260) |
| E-03 | A-2 | D-2 | ControlFlow | - | - | - |
| E-04 | D-2 | A-2a | ControlFlow | [không có phim] | - | - |
| E-05 | D-2 | A-3 | ControlFlow | [khác] | - | - |
| E-06 | A-2a | FINAL-1 | ControlFlow | - | - | - |
| E-07 | A-3 | A-4 | ControlFlow | - | - | (450,540) |
| E-08 | A-4 | A-5 | ControlFlow | - | - | (150,640) |
| E-09 | A-5 | FINAL-2 | ControlFlow | - | - | - |

Hai partition: ACT-01 Khách và hệ thống (P-SYS); luồng 2a chỉ có hành động của hệ thống nên partition của khách không cần rộng thêm. Guard [khác] của D-2 là trường hợp có ít nhất một phim đang chiếu hoặc sắp chiếu.

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ |
|---|---|---|---|
| Q-175 | Đã trả lời (Theo đề xuất: Danh sách hiển thị tên phim, thể loại, thời lượng và độ tuổi được xem; mô tả và trailer chỉ hiển thị khi xem thông tin một phim; ngày khởi chiếu hiển thị kèm phim sắp chiếu). Danh sách phim đang chiếu và sắp chiếu hiển thị những thông tin nào của mỗi phim ngoài tên phim: thể loại, thời lượng, độ tuổi được xem, ngày khởi chiếu, ngày kết thúc chiếu, định dạng phát hành? | Dữ liệu ra 1 (dòng 3); P11a (màn hình danh sách phim) | Mục 1 nêu "danh sách phim đang chiếu và sắp chiếu" và "thông tin phim (tên, thể loại, thời lượng, độ tuổi được xem, mô tả, trailer)" như hai phần riêng, không nói danh sách hiển thị thông tin nào |

## Giả định

Không áp dụng (CHE_DO_GIA_DINH là NGHIEM_NGAT).

## Đề xuất sửa artifact trước

Không có

## Vấn đề còn mở

- Luồng 2a kết thúc thành công vì mục tiêu "biết phim đang chiếu, sắp chiếu" đạt được ở dạng danh sách rỗng; nếu chủ dự án coi đó là thất bại thì đổi đích kết thúc của 2a, không đổi cấu trúc luồng.
- Luồng chính có 5 bước, trong khoảng 3-15.
