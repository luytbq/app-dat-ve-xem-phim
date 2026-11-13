# P04 - Đặc tả use case UC-007 Xem lịch sử đặt vé - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P04 |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | 00-Conventions.md; 00-Concurrency.md (M1); project-profile.md; yeu-cau-dat-ve.md; P00-problem-brief.md 1.11; P01-actors.md 1.2; P02-usecases.md 1.8; P03-usecase-model.md 1.1; _BR-register.md (đầu lô, đã gộp BR-01 đến BR-93); P05-glossary.md 1.1; P06-supplementary-spec.md 1.3; UC-001-register-account.md 1.0 (đặc tả cùng lô, mẫu định dạng); UC-005-book-tickets.md 1.13 (vé và lần đặt do UC-005 tạo); UC-008-cancel-ticket.md 1.9, UC-009-check-ticket.md 1.6 (trạng thái vé); dải mã được cấp Q-155 đến 174, BR-94 đến 113 |
| Phạm vi | UC-007 |
| Mã Q, ASM cuối đã cấp | Q-160 (dải Q-155 đến 174 của lô, Q-159, Q-160 cấp ở use case này); không có ASM (NGHIEM_NGAT) |

## 1. Thông tin chung

| Thuộc tính | Giá trị |
|---|---|
| Mã use case | UC-007 |
| Tên use case | Xem lịch sử đặt vé (View Booking History) |
| Tác nhân chính | ACT-01 Khách |
| Tác nhân phụ | Không có |
| Mô tả ngắn | Use case này mô tả tương tác giữa khách và hệ thống khi khách muốn xem lại các lần đặt vé và các vé của mình. Kết quả là khách biết các lần đặt vé đã thực hiện và nội dung từng vé. |
| Sự kiện kích hoạt | Khách muốn xem lại vé đã đặt (EV-09) |
| Tiền điều kiện | Khách đã đăng nhập và đang có phiên làm việc (REQ-12). |
| Hậu điều kiện (thành công) | Khách đã được hiển thị các lần đặt vé của chính mình và các vé của lần đặt đã chọn; dữ liệu lần đặt và vé không thay đổi.<br>Khi kết thúc ở luồng 2a: khách đã được thông báo chưa có lần đặt vé nào; dữ liệu không thay đổi. |
| Hậu điều kiện tối thiểu | Không có luồng kết thúc thất bại: use case chỉ đọc dữ liệu nên không có dữ liệu nào thay đổi ở mọi luồng; khách không thấy nội dung của lần đặt không thuộc mình (luồng 4a). |
| Quan hệ | Không có |
| Điểm mở rộng | Không có |
| REQ | REQ-39 (theo P02); REQ-12 (tiền điều kiện; P02 ghi "-"); REQ-30, REQ-45, REQ-47, REQ-105, REQ-106 (tham chiếu, UC-005); REQ-40 (tham chiếu, UC-008); REQ-52 (tham chiếu, UC-009) |

## 2. Luồng sự kiện chính

| STT | Thực hiện bởi | Hành động |
|---|---|---|
| 1 | Khách | Yêu cầu xem lịch sử đặt vé. |
| 2 | Hệ thống | Hiển thị các lần đặt vé của chính khách (BR-94; vé nào được hiển thị: Q-159; xem Dữ liệu ra 1). |
| 3 | Khách | Chọn một lần đặt vé cần xem (xem Dữ liệu vào 1). |
| 4 | Hệ thống | Kiểm tra lần đặt đã chọn thuộc về khách (BR-94). |
| 5 | Hệ thống | Hiển thị các vé của lần đặt đã chọn (xem Dữ liệu ra 2). |

## 3. Luồng sự kiện thay thế và ngoại lệ

| STT | Điều kiện | Thực hiện bởi | Hành động | Quay lại / Kết thúc |
|---|---|---|---|---|
| 2a | Khách chưa có lần đặt vé nào | Hệ thống | Thông báo khách chưa có lần đặt vé nào. | Kết thúc use case (thành công) |
| 4a | Lần đặt đã chọn không thuộc về khách (BR-94) | Hệ thống | Từ chối hiển thị và thông báo quy tắc bị vi phạm (BR-94). | Quay lại bước 3 |

## 4. Luồng con

Không có

## 5. Dữ liệu vào và dữ liệu ra

Dữ liệu vào 1 (bước 3)

| STT | Trường dữ liệu | Mô tả | Bắt buộc | Điều kiện hợp lệ | Ví dụ |
|---|---|---|---|---|---|
| 1 | Lần đặt cần xem | Một lần đặt vé trong danh sách khách vừa được hiển thị (REQ-39) | Có | Một lần đặt trong Dữ liệu ra 1 và thuộc về khách (BR-94) | CB0001234 |

Dữ liệu ra 1 (bước 2)

Mỗi dòng là một lần đặt của khách.

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Mã đặt vé | Mã định danh lần đặt, duy nhất trên toàn hệ thống (REQ-106) | Văn bản; nguồn không quy định định dạng cụ thể của mã | CB0001234 |
| 2 | Thông tin khác của lần đặt | Thông tin giúp khách nhận ra lần đặt ngoài mã đặt vé | Chưa quy định (Q-160) | - |

Dữ liệu ra 2 (bước 5)

Mỗi vé của lần đặt hiển thị nội dung vé theo REQ-105; mỗi lần đặt có mỗi ghế một vé (REQ-30).

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Mã đặt vé | Mã của lần đặt chứa vé (REQ-106) | Văn bản; nguồn không quy định định dạng cụ thể của mã | CB0001234 |
| 2 | Tên phim | Phim của suất chiếu | Văn bản | Phim A |
| 3 | Định dạng phim | Định dạng của suất chiếu | Văn bản | 2D |
| 4 | Tên cụm rạp | Cụm rạp có suất chiếu | Văn bản | CineBook Cầu Giấy |
| 5 | Tên phòng chiếu và loại phòng | Phòng chiếu và loại phòng (thường, 4DX, IMAX) | Văn bản | Phòng 3 (IMAX) |
| 6 | Ngày và giờ bắt đầu suất chiếu | Thời điểm bắt đầu của suất chiếu | dd/mm/yyyy hh:mm | 15/11/2026 19:30 |
| 7 | Vị trí ghế | Ghế ứng với vé | Mã hàng và số ghế | F7 |
| 8 | Loại ghế | Ghế thường, ghế VIP hoặc ghế đôi | Văn bản | Ghế VIP |
| 9 | Giá vé | Giá đã ghi trên vé | Số nguyên, phân cách hàng nghìn bằng dấu chấm, kèm "đ", căn phải | 120.000 đ |
| 10 | Mã QR của vé | Mã QR riêng của vé (REQ-105) | Hình mã QR | Mã QR của vé ghế F7 |
| 11 | Trạng thái vé | Tình trạng của vé: chưa sử dụng, đã sử dụng hoặc đã huỷ | Chưa quy định (Q-159) | - |

## 6. Quy tắc nghiệp vụ

| BR | Quy tắc | Loại | Bước áp dụng | REQ | Trong sổ BR |
|---|---|---|---|---|---|
| BR-94 | Khách chỉ xem lịch sử đặt vé và các vé của chính mình. | Ràng buộc | 2, 4, 4a, Dữ liệu vào 1 | REQ-39 | Mới |

Không có BR nào khác của sổ trùng nghĩa: BR-17 chỉ quy định ai được huỷ vé, không quy định ai được xem vé.

## 7. Yêu cầu đặc biệt

Không có

## 8. Thông tin bổ sung

- Luồng chính theo kịch bản của ACT-01 Khách, tác nhân chính duy nhất; use case không có tác nhân phụ.
- Lần đặt chỉ phát sinh khi một lần giữ ghế được mua thành công (GL-24, trả lời Q-68). Lần giữ ghế chưa hoàn tất, đã hết hạn, đã huỷ, thanh toán thất bại hoặc thanh toán đến trễ không có lần đặt và không có vé, nên không nằm trong lịch sử. Mở lại lần giữ ghế đang chạy để thanh toán thuộc UC-005 luồng 1a (trả lời Q-119), không thuộc use case này.
- Vé mua tại quầy không thuộc lịch sử của khách nào: khách mua tại quầy trả tiền mặt và không thao tác trên hệ thống (REQ-47, GL-19), nguồn không gắn vé mua tại quầy với tài khoản khách. Lịch sử chỉ gồm vé mua trực tuyến (GL-64).
- Nội dung mỗi vé hiển thị là nội dung do UC-005 tạo (REQ-105), kể cả mã QR; nguồn chỉ bỏ mã QR khi nhân viên soát vé xem vé (UC-009, trả lời Q-45), không bỏ khi khách xem vé của mình. Khi dịch vụ email không gửi được email chứa vé, khách vẫn thấy vé trong lịch sử (BR-89, UC-005 bước 14).
- Trạng thái vé: vé đã huỷ do UC-008 đặt (REQ-40), vé đã sử dụng do UC-009 đặt (REQ-52), tên giá trị theo trả lời Q-73. Trường Trạng thái vé ở Dữ liệu ra 2 và việc lịch sử có gồm vé đã huỷ, vé đã sử dụng hay không chờ Q-159.
- Bước 4 kiểm tra lần đặt đã chọn thuộc về khách. Tình huống này chỉ xảy ra khi yêu cầu chọn một lần đặt ngoài danh sách đã hiển thị (ví dụ mã đặt vé của người khác). Nguồn chỉ nêu "vé của mình" (REQ-39) mà không nêu phản hồi, nên theo F5.7 hệ thống từ chối và thông báo quy tắc bị vi phạm; quay lại bước 3 vì khách chọn lại được.
- Luồng 2a: danh sách rỗng là kết quả hợp lệ của việc xem lịch sử; hệ thống vẫn báo kết quả cho khách và use case đạt mục tiêu "khách biết các lần đặt vé" (Target 5a).
- Mô hình: các lần đặt hiển thị theo thứ tự lần đặt gần nhất trước, vì khách thường xem lại vé sắp dùng; nguồn không nêu thứ tự hiển thị và việc này không đổi luồng hay quy tắc.
- Use case không có tác nhân thời gian kích hoạt dùng dữ liệu của nó làm mốc, nên không có bước hẹn hoặc huỷ mốc (F4.2 mục 17).

Thao tác nguyên tử: Không có. Use case chỉ đọc. Lần đặt cùng các vé của nó do UC-005 tạo trong thao tác xử lý báo kết quả thanh toán (UC-005 bước 11, 12, 13, theo BR-85), nên khách thấy lần đặt cùng đủ vé hoặc chưa thấy lần đặt. Trạng thái vé do UC-008 (bước 4) và UC-009 (bước 5) đổi; use case này đọc trạng thái tại lúc hiển thị, không giữ bất biến nào cần loại trừ với hai use case đó, và vé vừa huỷ hoặc vừa soát hiện ở lần xem sau. Không có trạng thái dở dang.

## 8a. Kịch bản chính

- KB1: Luồng chính --> khách xem danh sách lần đặt vé của mình, chọn một lần đặt và xem các vé của lần đặt đó.
- KB2: Luồng chính + 2a --> khách chưa có lần đặt vé nào, hệ thống thông báo và use case kết thúc.
- KB3: Luồng chính + 4a --> lần đặt được chọn không thuộc khách bị từ chối, khách chọn lại từ bước 3.

## 9. Activity diagram

File: diagrams/P04-activity-UC-007.drawio

Bảng đối chiếu

| Bước UC | Node |
|---|---|
| 1 | A-1 |
| 2 | A-2, D-2 |
| 2a | D-2, A-2a |
| 3 | M-3, A-3 |
| 4 | A-4, D-4 |
| 4a | D-4, A-4a |
| 5 | A-5 |

Bảng Node

| ID | Loại | Nhãn | Stereotype | Thuộc về (container) | Bước UC | Ghi chú |
|---|---|---|---|---|---|---|
| P-ACT-01 | Partition | Khách | - | - | - | x=0, w=280 |
| P-SYS | Partition | Hệ thống | - | - | - | x=280, w=590 |
| INIT | Initial | - | - | P-ACT-01 | - | x=130, y=60 (tương đối partition) |
| A-1 | Action | Yêu cầu xem lịch sử đặt vé | - | P-ACT-01 | 1 | x=60, y=130 (tương đối partition) |
| A-2 | Action | Hiển thị các lần đặt vé của khách | - | P-SYS | 2 | x=60, y=230 (tương đối partition) |
| D-2 | Decision | - | - | P-SYS | 2, 2a | x=130, y=340 (tương đối partition) |
| A-2a | Action | Thông báo chưa có lần đặt vé nào | - | P-SYS | 2a | x=250, y=330 (tương đối partition) |
| FINAL-2 | ActivityFinal | - | - | P-SYS | 2a | x=510, y=340 (tương đối partition) |
| M-3 | Merge | - | - | P-ACT-01 | 3 | x=130, y=430 (tương đối partition) |
| A-3 | Action | Chọn một lần đặt vé | - | P-ACT-01 | 3 | x=60, y=500 (tương đối partition) |
| A-4 | Action | Kiểm tra lần đặt thuộc khách | - | P-SYS | 4 | x=60, y=600 (tương đối partition) |
| D-4 | Decision | - | - | P-SYS | 4, 4a | x=130, y=710 (tương đối partition) |
| A-4a | Action | Từ chối: lần đặt không thuộc khách (BR-94) | - | P-SYS | 4a | x=250, y=700 (tương đối partition) |
| A-5 | Action | Hiển thị các vé của lần đặt | - | P-SYS | 5 | x=60, y=800 (tương đối partition) |
| FINAL-1 | ActivityFinal | - | - | P-SYS | 5 | x=130, y=910 (tương đối partition) |

Bảng Edge

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú | Điểm uốn |
|---|---|---|---|---|---|---|
| E-01 | INIT | A-1 | ControlFlow | - | - | - |
| E-02 | A-1 | A-2 | ControlFlow | - | - | (150,260) |
| E-03 | A-2 | D-2 | ControlFlow | - | - | - |
| E-04 | D-2 | A-2a | ControlFlow | [khách chưa có lần đặt vé] | - | - |
| E-05 | D-2 | M-3 | ControlFlow | [khách có lần đặt vé] | - | (430,450) |
| E-06 | A-2a | FINAL-2 | ControlFlow | - | - | - |
| E-07 | M-3 | A-3 | ControlFlow | - | - | - |
| E-08 | A-3 | A-4 | ControlFlow | - | - | (150,630) |
| E-09 | A-4 | D-4 | ControlFlow | - | - | - |
| E-10 | D-4 | A-4a | ControlFlow | [lần đặt không thuộc khách] | - | - |
| E-11 | D-4 | A-5 | ControlFlow | [lần đặt thuộc khách] | - | - |
| E-12 | A-4a | M-3 | ControlFlow | - | - | (620,450) |
| E-13 | A-5 | FINAL-1 | ControlFlow | - | - | - |

Partition P-ACT-01 là partition của ACT-01 Khách, P-SYS là partition của chủ ngữ hệ thống. Decision D-2 và D-4 đặt trong partition hệ thống vì hệ thống đánh giá điều kiện. Luồng 2a là nhánh từ D-2 tới action A-2a rồi FINAL-2. Cạnh E-12 quay lại merge node M-3 đặt ngay trước A-3 và hợp với E-05 ở đoạn ngang trước M-3.

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ | Người quyết | Đề xuất |
|---|---|---|---|---|---|
| Q-159 | Lịch sử đặt vé của khách gồm toàn bộ vé từng mua (kể cả vé đã huỷ, vé đã sử dụng, vé của suất chiếu đã qua) hay chỉ vé còn hiệu lực? | Bước 2, 5; Dữ liệu ra 1, 2 (trường Trạng thái vé); BR mới nếu chỉ vé còn hiệu lực | Mục 11 chỉ nêu "xem lịch sử đặt vé và vé của mình", không nêu vé nào được hiển thị và có hiển thị trạng thái vé hay không | Bên nghiệp vụ | Toàn bộ vé từng mua, mỗi vé kèm trạng thái chưa sử dụng, đã sử dụng hoặc đã huỷ |
| Q-160 | Mỗi lần đặt trong danh sách lịch sử hiển thị những thông tin nào ngoài mã đặt vé? | Bước 2; Dữ liệu ra 1 | Mục 11 không nêu nội dung danh sách lịch sử; Mục 7 chỉ nêu nội dung của từng vé | Nhóm dự án | Tên phim, tên cụm rạp, ngày giờ bắt đầu suất chiếu và số vé của lần đặt |

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P06 | Mục truy vết UC-007 (cột BR) | UC-007 chưa có BR trong bảng truy vết use case | Thêm BR-94 cho UC-007 khi X3 gộp sổ BR |
| P05 | GL-18 (cột Ghi chú) | Ghi chú còn nêu UC-007 "chưa có đặc tả P04" | Bỏ cụm "chưa có đặc tả P04" ở phần UC-007 khi chạy lại P05 |

## Vấn đề còn mở

- Q-159, Q-160 chưa được trả lời; Dữ liệu ra 1 trường 2 và Dữ liệu ra 2 trường 11 ghi "Chưa quy định" theo NGHIEM_NGAT và không dựa vào đề xuất.
- Luồng chính có 5 bước, nằm trong khoảng 3-15.
- Dải mã được cấp cho lô là Q-155 đến 174 và BR-94 đến 113; use case này dùng Q-159, Q-160 và BR-94.
- Trên activity diagram, cạnh E-12 và E-05 hợp ở đoạn ngang trước M-3; không cạnh nào cắt qua node.
