# P04 - Đặc tả use case UC-004 Tra cứu lịch chiếu - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P04 |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | 00-Conventions.md; 00-Concurrency.md; project-profile.md; yeu-cau-dat-ve.md; P00-problem-brief.md 1.11; P01-actors.md 1.2; P02-usecases.md 1.8; P03-usecase-model.md 1.1; _BR-register.md (đầu lô); P05-glossary.md 1.1; P06-supplementary-spec.md 1.3; UC-005-book-tickets.md 1.13 và UC-014-schedule-showtimes.md 1.5 (nhất quán thời điểm mở bán, giờ bắt đầu, xoá suất chiếu, trạng thái ghế); dải mã đã được cấp: Q-175 đến Q-194, BR-114 đến BR-133 |
| Phạm vi | UC-004 |
| Mã Q, ASM cuối đã cấp | Q-180 (Q-176 đến Q-180 cấp ở UC-004); không có ASM (NGHIEM_NGAT) |

## 1. Thông tin chung

| Thuộc tính | Giá trị |
|---|---|
| Mã use case | UC-004 |
| Tên use case | Tra cứu lịch chiếu (Browse Showtimes) |
| Tác nhân chính | ACT-01 Khách |
| Tác nhân phụ | Không có |
| Mô tả ngắn | Use case này mô tả tương tác giữa khách và hệ thống khi khách muốn biết các suất chiếu phù hợp với phim, cụm rạp, ngày, loại phòng và định dạng phim mình quan tâm. Kết quả là khách nắm được lịch chiếu để chọn suất chiếu muốn đặt vé. |
| Sự kiện kích hoạt | Khách muốn biết lịch chiếu (EV-04) |
| Tiền điều kiện | Không có (khách không cần đăng nhập, REQ-08, REQ-09). |
| Hậu điều kiện (thành công) | Dữ liệu của hệ thống không thay đổi.<br>Khách đã được hiển thị các suất chiếu thoả các tiêu chí khách đã chọn.<br>Khi kết thúc ở luồng 4a hoặc 1a4a: khách đã được thông báo không có suất chiếu phù hợp; dữ liệu của hệ thống không thay đổi.<br>Khi kết thúc ở luồng 1a5: khách đã được hiển thị lịch chiếu của cụm rạp đã chọn. |
| Hậu điều kiện tối thiểu | Không có luồng kết thúc thất bại; mọi luồng đều không lưu thay đổi dữ liệu nào. |
| Quan hệ | Không có |
| Điểm mở rộng | Không có |
| REQ | REQ-08, REQ-09, REQ-10 (theo P02); REQ-61, REQ-140 (tham chiếu, UC-014); REQ-54 (tham chiếu, UC-011); REQ-02 (tham chiếu, UC-012); REQ-55 (tham chiếu, UC-010); REQ-86, REQ-135 (tham chiếu, UC-005; Mục 8); REQ-137 (tham chiếu, UC-014; Mục 8); REQ-14, REQ-15 (tham chiếu, UC-005; Mục 8) |

## 2. Luồng sự kiện chính

| STT | Thực hiện bởi | Hành động |
|---|---|---|
| 1 | Khách | Yêu cầu xem lịch chiếu theo phim. |
| 2 | Hệ thống | Hiển thị danh sách phim để chọn (xem Dữ liệu ra 1). |
| 3 | Khách | Chọn một phim, kèm các tiêu chí lọc tuỳ ý (xem Dữ liệu vào 1). |
| 4 | Hệ thống | Xác định các suất chiếu của phim đã chọn ở các cụm rạp, thoả mọi tiêu chí lọc đã chọn (BR-58; suất chiếu chưa mở bán: chưa quy định, Q-176; suất chiếu đã tới giờ bắt đầu: chưa quy định, Q-177). |
| 5 | Hệ thống | Hiển thị lịch chiếu gồm các suất chiếu đã xác định (xem Dữ liệu ra 2). |

## 3. Luồng sự kiện thay thế và ngoại lệ

| STT | Điều kiện | Thực hiện bởi | Hành động | Quay lại / Kết thúc |
|---|---|---|---|---|
| 1a | Khách chọn xem lịch chiếu theo cụm rạp thay vì theo phim | - | Xem lịch chiếu theo cụm rạp | - |
| 1a1 | | Khách | Yêu cầu xem lịch chiếu theo cụm rạp. | |
| 1a2 | | Hệ thống | Hiển thị danh sách cụm rạp để chọn (xem Dữ liệu ra 3). | |
| 1a3 | | Khách | Chọn một cụm rạp, kèm các tiêu chí lọc tuỳ ý (xem Dữ liệu vào 2). | |
| 1a4 | | Hệ thống | Xác định các suất chiếu tại cụm rạp đã chọn, thoả mọi tiêu chí lọc đã chọn (BR-58; suất chiếu chưa mở bán: chưa quy định, Q-176; suất chiếu đã tới giờ bắt đầu: chưa quy định, Q-177). | |
| 1a4a | Không có suất chiếu nào tại cụm rạp đã chọn thoả các tiêu chí lọc đã chọn | Hệ thống | Thông báo không có suất chiếu phù hợp. | Kết thúc use case (thành công) |
| 1a5 | | Hệ thống | Hiển thị lịch chiếu gồm các suất chiếu đã xác định ở bước 1a4 (xem Dữ liệu ra 2). | Kết thúc use case (thành công) |
| 4a | Không có suất chiếu nào của phim đã chọn thoả các tiêu chí lọc đã chọn | Hệ thống | Thông báo không có suất chiếu phù hợp. | Kết thúc use case (thành công) |

## 4. Luồng con

Không có

## 5. Dữ liệu vào và dữ liệu ra

Dữ liệu vào 1 (bước 3)

| STT | Trường dữ liệu | Mô tả | Bắt buộc | Điều kiện hợp lệ | Ví dụ |
|---|---|---|---|---|---|
| 1 | Phim | Phim khách muốn xem lịch chiếu (REQ-08) | Có | Thuộc danh sách phim đã hiển thị ở bước 2 | Phim A |
| 2 | Tỉnh, thành phố | Lọc lịch chiếu theo tỉnh, thành phố của cụm rạp (REQ-10) | Không | Là một tỉnh, thành phố có cụm rạp của chuỗi (REQ-10) | Hà Nội |
| 3 | Ngày | Lọc lịch chiếu theo ngày chiếu (REQ-10) | Không | Chưa quy định (Q-179) | 15/11/2026 |
| 4 | Loại phòng | Lọc lịch chiếu theo loại phòng của phòng chiếu (REQ-10) | Không | Một trong phòng thường, 4DX, IMAX (REQ-02) | IMAX |
| 5 | Định dạng phim | Lọc lịch chiếu theo định dạng của suất chiếu (REQ-10) | Không | Một trong 2D, 3D (REQ-55) | 2D |

Dữ liệu vào 2 (bước 1a3)

| STT | Trường dữ liệu | Mô tả | Bắt buộc | Điều kiện hợp lệ | Ví dụ |
|---|---|---|---|---|---|
| 1 | Cụm rạp | Cụm rạp khách muốn xem lịch chiếu (REQ-09) | Có | Thuộc danh sách cụm rạp đã hiển thị ở bước 1a2 | Cụm rạp X |
| 2 | Tỉnh, thành phố | Như Dữ liệu vào 1 dòng 2 | Không | Như Dữ liệu vào 1 dòng 2 | Hà Nội |
| 3 | Ngày | Như Dữ liệu vào 1 dòng 3 | Không | Chưa quy định (Q-179) | 15/11/2026 |
| 4 | Loại phòng | Như Dữ liệu vào 1 dòng 4 | Không | Như Dữ liệu vào 1 dòng 4 | IMAX |
| 5 | Định dạng phim | Như Dữ liệu vào 1 dòng 5 | Không | Như Dữ liệu vào 1 dòng 5 | 2D |

Dữ liệu ra 1 (bước 2)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Tên phim | Tên của từng phim để khách chọn; các phim được liệt kê: chưa quy định (Q-180) | Văn bản | Phim A |

Dữ liệu ra 2 (bước 5, bước 1a5)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Phim | Tên phim của suất chiếu (REQ-61) | Văn bản | Phim A |
| 2 | Định dạng | Định dạng phim của suất chiếu (REQ-61) | Văn bản | 2D |
| 3 | Cụm rạp | Tên cụm rạp có suất chiếu (REQ-08, REQ-09) | Văn bản | Cụm rạp X |
| 4 | Phòng chiếu | Tên phòng chiếu của suất chiếu (REQ-61) | Văn bản | Phòng 3 |
| 5 | Ngày giờ bắt đầu | Ngày và giờ bắt đầu của suất chiếu (REQ-61) | Dạng dd/mm/yyyy hh:mm | 15/11/2026 19:30 |
| 6 | Loại phòng, tỉnh hoặc thành phố của cụm rạp, giờ kết thúc, thời điểm mở bán, giá vé, số ghế còn trống | Chưa quy định (Q-178) | Chưa quy định (Q-178) | Chưa quy định (Q-178) |

Dữ liệu ra 3 (bước 1a2)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Tên cụm rạp | Tên của từng cụm rạp trong danh sách cụm rạp của chuỗi (REQ-54) | Văn bản | Cụm rạp X |

## 6. Quy tắc nghiệp vụ

| BR | Quy tắc | Loại | Bước áp dụng | REQ | Trong sổ BR |
|---|---|---|---|---|---|
| BR-58 | Xoá suất chiếu là bỏ suất chiếu khỏi lịch chiếu và ngừng bán vé của suất chiếu đó; thông tin của suất chiếu vẫn được giữ cho vé đã huỷ, hoàn tiền (kể cả thanh toán trễ) và báo cáo. | Ràng buộc | 4, 1a4, Dữ liệu ra 2 | REQ-140 | Đã có |

## 7. Yêu cầu đặc biệt

Không có

## 8. Thông tin bổ sung

- Nhất quán với thời điểm mở bán và giờ bắt đầu. Một suất chiếu bán được vé trong khoảng từ thời điểm mở bán (BR-01) tới trước giờ bắt đầu (BR-45), và thời điểm mở bán luôn trước giờ bắt đầu (BR-55). Tra cứu lịch chiếu không phải đặt hoặc mua vé nên không bị BR-01 và BR-45 chặn; việc từ chối suất chiếu chưa mở bán hoặc đã tới giờ bắt đầu nằm ở UC-005 bước 2 (luồng 2a, 2c). Vì vậy một suất chiếu có trong lịch chiếu không bảo đảm suất chiếu đó đang bán được vé. Suất chiếu nào được liệt kê theo thời điểm mở bán và giờ bắt đầu chờ Q-176, Q-177.
- Trạng thái ghế (trống, đang được giữ, đã bán; REQ-15) và sơ đồ ghế hiển thị ở UC-005 bước 3 (REQ-14), không thuộc lịch chiếu. Số ghế còn trống chỉ hiển thị khi Q-178 chốt; khi đó chỉ ghế ở trạng thái trống được tính là còn trống, nhất quán với UC-005.
- Suất chiếu đã xoá (UC-014 luồng 1b, BR-58) không có trong lịch chiếu vì đã bị bỏ khỏi lịch chiếu; dữ liệu của suất chiếu đó chỉ còn phục vụ vé đã huỷ, hoàn tiền và báo cáo.
- Các tiêu chí lọc khách đã cung cấp cùng áp dụng cho kết quả (Mô hình: lọc nhiều tiêu chí là giao các điều kiện). Khách không cung cấp tiêu chí nào thì kết quả không bị giới hạn bởi tiêu chí đó. Tỉnh, thành phố là một tiêu chí (REQ-10 gọi chung "tỉnh, thành phố"). Các tiêu chí lọc áp dụng như nhau ở cả hai cách tra cứu (theo phim, theo cụm rạp) vì nguồn không phân biệt.
- Danh sách cụm rạp ở bước 1a2 gồm mọi cụm rạp trong danh sách cụm rạp của chuỗi (REQ-54, UC-011).
- UC-014 sửa hoặc xoá suất chiếu trong lúc khách xem lịch chiếu chỉ làm các lần tra cứu sau thấy dữ liệu mới. Khách chọn suất chiếu để đặt vé ở UC-005 bước 1; nếu suất chiếu đã bị sửa hoặc xoá thì UC-005 từ chối giữ ghế (BR-54, luồng 7d).
- Nguồn không nêu thứ tự sắp xếp các suất chiếu trong kết quả; thứ tự là cách trình bày thuộc thiết kế giao diện.
- Use case do tác nhân người kích hoạt, không có use case nào do tác nhân thời gian kích hoạt dùng dữ liệu của use case này làm mốc, nên không có bước hẹn hoặc huỷ mốc (F4.2 mục 17).
- Không có trao đổi với hệ thống ngoài.
- Bước sinh theo quy tắc của prompt: bước 5, luồng 1a5 báo kết quả cho khách; luồng 4a và 1a4a thông báo kết quả rỗng theo Target 5a.
- Tải đồng thời: use case chỉ đọc lịch chiếu, không đọc hoặc ghi ghế, giao dịch thanh toán, yêu cầu hoàn tiền; số ghế còn trống, nếu hiển thị theo Q-178, chỉ là dữ liệu đọc tại lúc xem, không giữ chỗ.

Thao tác nguyên tử: Không có

## 8a. Kịch bản chính

- KB1: Luồng chính --> khách chọn phim, xem lịch chiếu của phim.
- KB2: Luồng 1a --> khách chọn cụm rạp, xem lịch chiếu của cụm rạp.
- KB3: Luồng chính + 4a --> không có suất chiếu của phim thoả tiêu chí lọc, khách nhận thông báo.
- KB4: Luồng 1a + 1a4a --> không có suất chiếu tại cụm rạp thoả tiêu chí lọc, khách nhận thông báo.

## 9. Activity diagram

File: diagrams/P04-activity-UC-004.drawio

Bảng đối chiếu

| Bước UC | Node |
|---|---|
| 1 | A-1, D-1 |
| 1a1 | A-1a1 |
| 1a2 | A-1a2 |
| 1a3 | A-1a3 |
| 1a4 | A-1a4, D-1a4 |
| 1a4a | A-1a4a, FINAL-3 |
| 1a5 | A-1a5, FINAL-4 |
| 2 | A-2 |
| 3 | A-3 |
| 4 | A-4, D-4 |
| 4a | A-4a, FINAL-1 |
| 5 | A-5, FINAL-2 |

Bảng Node

| ID | Loại | Nhãn | Stereotype | Thuộc về (container) | Bước UC | Ghi chú |
|---|---|---|---|---|---|---|
| P-ACT-01 | Partition | Khách | - | - | - | x=0, w=520 |
| P-SYS | Partition | Hệ thống | - | - | - | x=520, w=760 |
| INIT | Initial | - | - | P-ACT-01 | - | x=130, y=60 (tương đối partition) |
| D-1 | Decision | - | - | P-ACT-01 | 1a | x=130, y=140 (tương đối partition) |
| A-1 | Action | Yêu cầu xem lịch chiếu theo phim | - | P-ACT-01 | 1 | x=60, y=230 (tương đối partition) |
| A-1a1 | Action | Yêu cầu xem lịch chiếu theo cụm rạp | - | P-ACT-01 | 1a1 | x=300, y=130 (tương đối partition) |
| A-1a2 | Action | Hiển thị danh sách cụm rạp | - | P-SYS | 1a2 | x=300, y=210 (tương đối partition) |
| A-1a3 | Action | Chọn cụm rạp và tiêu chí lọc | - | P-ACT-01 | 1a3 | x=300, y=270 (tương đối partition) |
| A-1a4 | Action | Xác định suất chiếu tại cụm rạp (BR-58) | - | P-SYS | 1a4 | x=300, y=410 (tương đối partition) |
| D-1a4 | Decision | - | - | P-SYS | 1a4a | x=370, y=510 (tương đối partition) |
| A-1a4a | Action | Thông báo không có suất chiếu phù hợp | - | P-SYS | 1a4a | x=540, y=500 (tương đối partition) |
| FINAL-3 | ActivityFinal | - | - | P-SYS | - | x=610, y=600 (tương đối partition) |
| A-1a5 | Action | Hiển thị lịch chiếu của cụm rạp | - | P-SYS | 1a5 | x=300, y=590 (tương đối partition) |
| FINAL-4 | ActivityFinal | - | - | P-SYS | - | x=370, y=690 (tương đối partition) |
| A-2 | Action | Hiển thị danh sách phim để chọn | - | P-SYS | 2 | x=60, y=330 (tương đối partition) |
| A-3 | Action | Chọn phim và tiêu chí lọc | - | P-ACT-01 | 3 | x=60, y=520 (tương đối partition) |
| A-4 | Action | Xác định suất chiếu của phim (BR-58) | - | P-SYS | 4 | x=60, y=630 (tương đối partition) |
| D-4 | Decision | - | - | P-SYS | 4a | x=130, y=740 (tương đối partition) |
| A-4a | Action | Thông báo không có suất chiếu phù hợp | - | P-SYS | 4a | x=540, y=730 (tương đối partition) |
| FINAL-1 | ActivityFinal | - | - | P-SYS | - | x=610, y=830 (tương đối partition) |
| A-5 | Action | Hiển thị lịch chiếu của phim | - | P-SYS | 5 | x=60, y=830 (tương đối partition) |
| FINAL-2 | ActivityFinal | - | - | P-SYS | - | x=130, y=930 (tương đối partition) |

Bảng Edge

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú | Điểm uốn |
|---|---|---|---|---|---|---|
| E-01 | INIT | D-1 | ControlFlow | - | - | - |
| E-02 | D-1 | A-1 | ControlFlow | [theo phim] | - | - |
| E-03 | D-1 | A-1a1 | ControlFlow | [theo cụm rạp] | - | - |
| E-04 | A-1 | A-2 | ControlFlow | - | - | (150,360) |
| E-05 | A-2 | A-3 | ControlFlow | - | - | (670,550) |
| E-06 | A-3 | A-4 | ControlFlow | - | - | (150,660) |
| E-07 | A-4 | D-4 | ControlFlow | - | - | - |
| E-08 | D-4 | A-4a | ControlFlow | [không có suất chiếu phù hợp] | - | - |
| E-09 | D-4 | A-5 | ControlFlow | [khác] | - | - |
| E-10 | A-4a | FINAL-1 | ControlFlow | - | - | - |
| E-11 | A-5 | FINAL-2 | ControlFlow | - | - | - |
| E-12 | A-1a1 | A-1a2 | ControlFlow | - | - | (390,240) |
| E-13 | A-1a2 | A-1a3 | ControlFlow | - | - | (910,300) |
| E-14 | A-1a3 | A-1a4 | ControlFlow | - | - | (390,440) |
| E-15 | A-1a4 | D-1a4 | ControlFlow | - | - | - |
| E-16 | D-1a4 | A-1a4a | ControlFlow | [không có suất chiếu phù hợp] | - | - |
| E-17 | D-1a4 | A-1a5 | ControlFlow | [khác] | - | - |
| E-18 | A-1a4a | FINAL-3 | ControlFlow | - | - | - |
| E-19 | A-1a5 | FINAL-4 | ControlFlow | - | - | - |

Hai partition: ACT-01 Khách (rộng 520 vì luồng 1a có hành động của khách) và hệ thống (P-SYS). D-1 đặt trong partition của khách, ngay trước A-1, vì luồng 1a là cách làm khác thay cho chính bước 1 do khách chọn (F5.2). Guard [khác] của D-4 và D-1a4 là trường hợp có ít nhất một suất chiếu phù hợp. Một số cạnh giao nhau ở vùng giữa hai partition; không cạnh nào cắt qua node.

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ | Người quyết | Đề xuất |
|---|---|---|---|---|---|
| Q-176 | Lịch chiếu có hiển thị suất chiếu chưa tới thời điểm mở bán không? | Bước 4, 1a4; Dữ liệu ra 2 (thêm thời điểm mở bán nếu hiển thị) | Mục 16 chỉ nêu "trước thời điểm mở bán, không ai đặt hoặc mua được vé của suất chiếu đó", không nêu việc xem lịch chiếu của suất chưa mở bán | Bên nghiệp vụ | Có hiển thị, kèm thời điểm mở bán để khách biết khi nào đặt được; việc từ chối đặt vé vẫn do UC-005 bước 2 |
| Q-177 | Lịch chiếu có hiển thị suất chiếu đã tới giờ bắt đầu, kể cả đã kết thúc, không? | Bước 4, 1a4 | Mục 16 nêu "từ giờ bắt đầu của suất chiếu, hệ thống ngừng bán vé", không nêu việc xem lịch chiếu của suất đã bắt đầu | Bên nghiệp vụ | Không hiển thị suất chiếu đã tới giờ bắt đầu vì không còn bán vé (BR-45); lịch chiếu chỉ gồm suất chưa bắt đầu |
| Q-178 | Mỗi suất chiếu trong lịch chiếu hiển thị những thông tin nào ngoài phim, định dạng, cụm rạp, phòng chiếu và ngày giờ bắt đầu: loại phòng, tỉnh hoặc thành phố của cụm rạp, giờ kết thúc, thời điểm mở bán, giá vé, số ghế còn trống? | Dữ liệu ra 2 dòng 6; dữ liệu ra 3 | Mục 2 chỉ nêu "xem các suất chiếu", không nêu thông tin hiển thị của suất chiếu | Bên nghiệp vụ | Hiển thị thêm loại phòng và tỉnh hoặc thành phố của cụm rạp (để khớp các tiêu chí lọc); không hiển thị giờ kết thúc, giá vé, số ghế còn trống (khách xem giá và ghế ở UC-005); thời điểm mở bán chỉ hiển thị theo đáp án Q-176 |
| Q-179 | Tiêu chí lọc theo ngày là một ngày hay một khoảng ngày? | Dữ liệu vào 1 và 2 dòng 3 | Mục 2 nêu "lọc ... theo ngày", không nêu một ngày hay khoảng ngày | Bên nghiệp vụ | Một ngày duy nhất, so với ngày của giờ bắt đầu suất chiếu |
| Q-180 | Khi xem lịch chiếu theo phim, danh sách phim để chọn gồm những phim nào: chỉ phim đang chiếu và sắp chiếu (BR-76), hay mọi phim trong danh sách phim của chuỗi? | Dữ liệu ra 1; bước 2 | Mục 2 nêu "chọn phim rồi xem các suất chiếu của phim đó", Mục 1 và Mục 14 chỉ định nghĩa phim đang chiếu, sắp chiếu cho việc xem danh sách phim | Bên nghiệp vụ | Phim đang chiếu và phim sắp chiếu theo BR-76 (cùng nhóm phim với UC-003) |

## Giả định

Không áp dụng (CHE_DO_GIA_DINH là NGHIEM_NGAT).

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P06 | Bảng UC --> NFR / BR, dòng UC-004 | Dòng UC-004 ghi "-" cột BR, trong khi đặc tả này áp dụng BR-58 (suất chiếu đã xoá bị bỏ khỏi lịch chiếu) | Thêm BR-58 vào dòng UC-004; cột UC áp dụng của BR-58 trong sổ BR thêm UC-004 (đã ghi ở file pending) |
| P05 | GL-47, mục Lịch chiếu ở bảng đồng nghĩa | Cột Ghi chú còn ghi "Chưa có đặc tả P04: UC-004" | Chạy lại P05 sau khi X3 gộp đặc tả UC-004 để cập nhật cột này |

## Vấn đề còn mở

- Q-176, Q-177 chưa trả lời: điều kiện thời điểm mở bán và giờ bắt đầu của bước 4 và 1a4 ghi "chưa quy định". Đáp án làm thay đổi tập suất chiếu được liệt kê, không thêm luồng rẽ; riêng đáp án có hiển thị suất chưa mở bán (Q-176) làm thêm trường thời điểm mở bán ở Dữ liệu ra 2.
- Q-179 chưa trả lời: nếu đáp án là khoảng ngày thì Dữ liệu vào 1 và 2 thêm hai trường (từ ngày, đến ngày) và thêm luồng thay thế tại bước 3 và 1a3 cho khoảng ngày có ngày bắt đầu sau ngày kết thúc (nếu đáp án một ngày thì không có luồng này).
- Q-180 chưa trả lời: Dữ liệu ra 1 ghi "các phim được liệt kê: chưa quy định".
- Luồng chính có 5 bước, trong khoảng 3-15.
- Bố cục activity diagram: một số cạnh giao nhau ở vùng giữa hai partition vì luồng 1a và luồng chính cùng đi qua hai partition; không cạnh nào cắt qua node, không node nào chồng nhau.
