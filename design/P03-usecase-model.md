# P03 - Mô hình use case - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P03 |
| Phiên bản | 1.1 |
| Thay đổi 1.1 | Đồng bộ số phiên bản và nhãn BR của dòng Đầu vào đã dùng với bản hiện hành; nội dung đã đối chiếu lại ở lượt review cuối (design/_review-final.md, RF-06) |
| Đầu vào đã dùng | 00-Conventions.md; project-profile.md (mục 4: đăng nhập không là use case); P00-problem-brief.md 1.11; P01-actors.md 1.2; P02-usecases.md 1.8; yeu-cau-dat-ve.md. P02R 1.0: UCR-01, UCR-02 đã áp dụng ở P02 1.2 |
| Phạm vi | Toàn hệ thống |
| Mã Q, ASM cuối đã cấp | Q-23; không có ASM (NGHIEM_NGAT) |

Kiểu đường association: KHONG_MUI_TEN (mặc định). Cách phân rã sơ đồ: không cần sơ đồ phân rã (Bước 8).

## 1. Bảng quan hệ

| ID | Nguồn | Đích | Loại | Điều kiện extend / điểm mở rộng | Lý do | REQ | Sơ đồ |
|---|---|---|---|---|---|---|---|
| RL-01 | ACT-01 | UC-001 | Association | - | Tác nhân chính | REQ-11 | Tổng quát |
| RL-02 | ACT-01 | UC-003 | Association | - | Tác nhân chính | REQ-05, REQ-06 | Tổng quát |
| RL-03 | ACT-01 | UC-004 | Association | - | Tác nhân chính | REQ-08, REQ-09, REQ-10 | Tổng quát |
| RL-04 | ACT-01 | UC-005 | Association | - | Tác nhân chính | REQ-13, REQ-14, REQ-21, REQ-28 | Tổng quát |
| RL-05 | ACT-02 | UC-005 | Association | - | Tác nhân chính (U-R10 b: bán vé tại quầy) | REQ-45, REQ-48, REQ-49 | Tổng quát |
| RL-06 | ACT-07 | UC-005 | Association | - | Tác nhân phụ: tạo giao dịch thanh toán, báo kết quả giao dịch trong thời gian giữ ghế | REQ-28, REQ-29, REQ-34, REQ-79 | Tổng quát |
| RL-07 | ACT-08 | UC-005 | Association | - | Tác nhân phụ: gửi email chứa vé | REQ-31, REQ-80 | Tổng quát |
| RL-08 | ACT-07 | UC-006 | Association | - | Tác nhân chính (báo thanh toán thành công sau thời điểm hết hạn giữ ghế); đồng thời là tác nhân phụ thực hiện hoàn tiền trong cùng UC, vẽ một association | REQ-35, REQ-36, REQ-79 | Tổng quát |
| RL-09 | ACT-08 | UC-006 | Association | - | Tác nhân phụ: gửi email thông báo hoàn tiền | REQ-90, REQ-80 | Tổng quát |
| RL-10 | ACT-01 | UC-007 | Association | - | Tác nhân chính | REQ-39 | Tổng quát |
| RL-11 | ACT-01 | UC-008 | Association | - | Tác nhân chính | REQ-40 | Tổng quát |
| RL-12 | ACT-02 | UC-008 | Association | - | Tác nhân chính (U-R10 b: huỷ vé mua tại quầy) | REQ-83 | Tổng quát |
| RL-13 | ACT-07 | UC-008 | Association | - | Tác nhân phụ: hoàn tiền vé bị huỷ | REQ-43, REQ-79 | Tổng quát |
| RL-14 | ACT-03 | UC-009 | Association | - | Tác nhân chính | REQ-50, REQ-93 | Tổng quát |
| RL-15 | ACT-05 | UC-010 | Association | - | Tác nhân chính | REQ-53 | Tổng quát |
| RL-16 | ACT-05 | UC-011 | Association | - | Tác nhân chính | REQ-54 | Tổng quát |
| RL-17 | ACT-04 | UC-012 | Association | - | Tác nhân chính | REQ-56 | Tổng quát |
| RL-18 | ACT-04 | UC-013 | Association | - | Tác nhân chính | REQ-59 | Tổng quát |
| RL-19 | ACT-04 | UC-014 | Association | - | Tác nhân chính | REQ-60 | Tổng quát |
| RL-20 | ACT-04 | UC-015 | Association | - | Tác nhân chính | REQ-66, REQ-67 | Tổng quát |
| RL-21 | ACT-05 | UC-016 | Association | - | Tác nhân chính | REQ-68, REQ-69 | Tổng quát |
| RL-22 | ACT-06 | UC-017 | Association | - | Tác nhân chính | REQ-70, REQ-71, REQ-72 | Tổng quát |

Không có quan hệ include, extend hay generalization giữa use case: P02 không giữ UC Subfunction nào theo Q4, không có UC mở rộng, và không có biến thể tách theo U-R12. Không có tổng quát hoá tác nhân ở P01.

## 2. Điểm mở rộng

Không có

## 3. UC đề xuất bổ sung

Không có

## 4. Danh sách sơ đồ

| Sơ đồ | Phạm vi | Tác nhân | Use case | File |
|---|---|---|---|---|
| Tổng quát | Toàn hệ thống, mọi phần tử và quan hệ (N = 16, M = 8) | ACT-01..ACT-08 | 16 UC | diagrams/P03-usecase-overview.drawio |

## 5. Bảng mô hình của từng sơ đồ

### Tổng quát

Bảng Node

| ID | Loại | Nhãn | Stereotype | Thuộc về (container) | Ghi chú | x | y | w | h |
|---|---|---|---|---|---|---|---|---|---|
| SYS | Boundary | Hệ thống đặt vé xem phim CineBook | - | - | Boundary (subject) | 200 | 40 | 980 | 1340 |
| ACT-01 | Actor | Khách | - | - | - | 60 | 170 | 30 | 60 |
| ACT-02 | Actor | Nhân viên quầy | - | - | Không có UC riêng; nối UC-005, UC-008 ở cột giữa (L-12) | 60 | 400 | 30 | 60 |
| ACT-03 | Actor | Nhân viên soát vé | - | - | - | 60 | 550 | 30 | 60 |
| ACT-04 | Actor | Quản lý cụm rạp | - | - | - | 60 | 780 | 30 | 60 |
| ACT-05 | Actor | Quản lý chuỗi | - | - | - | 60 | 1040 | 30 | 60 |
| ACT-06 | Actor | Quản trị viên | - | - | - | 60 | 1270 | 30 | 60 |
| ACT-08 | Actor | Dịch vụ email | «system» | - | Tác nhân phụ | 1260 | 300 | 30 | 60 |
| ACT-07 | Actor | Cổng thanh toán | «system» | - | Tác nhân chính ở UC-006, phụ ở UC-005, UC-008; đặt bên phải theo vai trò chiếm đa số (L-03) | 1260 | 440 | 30 | 60 |
| UC-001 | UseCase | Đăng ký tài khoản | - | SYS | - | 260 | 80 | 160 | 70 |
| UC-003 | UseCase | Tra cứu phim | - | SYS | - | 500 | 140 | 160 | 70 |
| UC-004 | UseCase | Tra cứu lịch chiếu | - | SYS | - | 260 | 190 | 160 | 70 |
| UC-007 | UseCase | Xem lịch sử đặt vé | - | SYS | - | 500 | 250 | 160 | 70 |
| UC-005 | UseCase | Đặt vé | - | SYS | Cột giữa: nối ACT-01, ACT-02 (L-12) | 740 | 340 | 160 | 70 |
| UC-008 | UseCase | Huỷ vé | - | SYS | Cột giữa: nối ACT-01, ACT-02 (L-12) | 740 | 450 | 160 | 70 |
| UC-006 | UseCase | Hoàn tiền thanh toán trễ | - | SYS | Cột bên phải: chỉ nối tác nhân bên phải (L-12) | 980 | 150 | 160 | 70 |
| UC-009 | UseCase | Soát vé | - | SYS | - | 260 | 540 | 160 | 70 |
| UC-012 | UseCase | Quản lý phòng chiếu | - | SYS | - | 260 | 690 | 160 | 70 |
| UC-013 | UseCase | Quản lý bảng giá | - | SYS | - | 500 | 750 | 160 | 70 |
| UC-014 | UseCase | Lập lịch suất chiếu | - | SYS | - | 260 | 800 | 160 | 70 |
| UC-015 | UseCase | Xem báo cáo cụm rạp | - | SYS | - | 500 | 860 | 160 | 70 |
| UC-010 | UseCase | Quản lý phim | - | SYS | - | 260 | 1010 | 160 | 70 |
| UC-011 | UseCase | Quản lý cụm rạp | - | SYS | - | 500 | 1070 | 160 | 70 |
| UC-016 | UseCase | Xem báo cáo toàn chuỗi | - | SYS | - | 260 | 1120 | 160 | 70 |
| UC-017 | UseCase | Quản lý tài khoản nhân viên | - | SYS | - | 260 | 1270 | 160 | 70 |

Bảng Edge

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú | Điểm uốn |
|---|---|---|---|---|---|---|
| RL-01 | ACT-01 | UC-001 | Association | - | - | - |
| RL-02 | ACT-01 | UC-003 | Association | - | - | (240,170) |
| RL-03 | ACT-01 | UC-004 | Association | - | - | - |
| RL-04 | ACT-01 | UC-005 | Association | - | - | (220,200); (220,370) |
| RL-05 | ACT-02 | UC-005 | Association | - | - | - |
| RL-06 | ACT-07 | UC-005 | Association | - | - | - |
| RL-07 | ACT-08 | UC-005 | Association | - | - | - |
| RL-08 | ACT-07 | UC-006 | Association | - | - | (1200,410) |
| RL-09 | ACT-08 | UC-006 | Association | - | - | - |
| RL-10 | ACT-01 | UC-007 | Association | - | - | (240,280) |
| RL-11 | ACT-01 | UC-008 | Association | - | - | (230,210); (230,480) |
| RL-12 | ACT-02 | UC-008 | Association | - | - | - |
| RL-13 | ACT-07 | UC-008 | Association | - | - | - |
| RL-14 | ACT-03 | UC-009 | Association | - | - | - |
| RL-15 | ACT-05 | UC-010 | Association | - | - | - |
| RL-16 | ACT-05 | UC-011 | Association | - | - | (240,1100) |
| RL-17 | ACT-04 | UC-012 | Association | - | - | - |
| RL-18 | ACT-04 | UC-013 | Association | - | - | (240,780) |
| RL-19 | ACT-04 | UC-014 | Association | - | - | - |
| RL-20 | ACT-04 | UC-015 | Association | - | - | (240,890) |
| RL-21 | ACT-05 | UC-016 | Association | - | - | - |
| RL-22 | ACT-06 | UC-017 | Association | - | - | - |

## 6. Nội dung file .drawio

- diagrams/P03-usecase-overview.drawio

## Câu hỏi mở

Không có

## Đề xuất sửa artifact trước

Không có

## Vấn đề còn mở

- Bố cục theo L-12 (16 UC). Cột hai lệch xuống 60 thay vì nửa bước dòng 55, vì Conventions C7.3 yêu cầu toạ độ là bội số của 10; tâm UC cột hai vẫn rơi vào khe giữa hai UC cột một.
- ACT-02 Nhân viên quầy không có UC riêng nên không có dải; hai UC dùng chung với ACT-01 (UC-005, UC-008) đặt ở cột giữa, đường nối từ ACT-01 đi qua điểm uốn tại x = 220, 230 (gần cạnh trái boundary).
- ACT-07 Cổng thanh toán là tác nhân chính của UC-006 nhưng đặt bên phải theo vai trò phụ chiếm đa số (UC-005, UC-008), theo L-03; association RL-08 vẫn thể hiện vai trò chính ở UC-006.
- UC-006 đặt ở cột bên phải, phía trên UC-005, để đường tới hai tác nhân bên phải không cắt qua nhãn tác nhân; không theo trình tự thời gian so với UC-005 (L-05) vì nằm ở cột riêng.
- Còn ba điểm giao nhau giữa hai đường nối (RL-05, RL-12 cắt đoạn dọc của RL-11; RL-08 cắt RL-07). Không đường nào cắt qua elip hay nhãn tác nhân (đã kiểm bằng script theo hình chữ nhật bao của từng UC).
