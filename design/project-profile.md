# Hồ sơ dự án (project-profile.md)

## 1. Thông tin chung

| Trường | Giá trị |
|---|---|
| TEN_HE_THONG | Hệ thống đặt vé xem phim CineBook |
| MO_TA_MOT_CAU | Cho phép khách đặt vé xem phim trực tuyến tại các cụm rạp của chuỗi và giúp nhân viên từng cụm rạp bán vé, soát vé trên cùng một sơ đồ ghế. |
| TAI_LIEU_NGUON | 1. yeu-cau-dat-ve.md |
| THU_MUC_DAU_RA | ./design/ |

## 2. Chế độ làm việc

| Trường | Giá trị |
|---|---|
| CHE_DO_GIA_DINH | NGHIEM_NGAT |
| NGON_NGU_DAU_RA | Tiếng Việt, giữ thuật ngữ UML tiếng Anh |
| NGON_NGU_TEN_PHAN_TU | Tiếng Anh, PascalCase cho lớp, camelCase cho thuộc tính và phương thức, snake_case cho bảng và cột |
| HAU_TO_TEN_LOP | Mặc định |
| MUC_CHI_TIET | DAY_DU |

## 3. Bối cảnh kỹ thuật

| Trường | Giá trị |
|---|---|
| NEN_TANG | Web app responsive |
| CONG_NGHE | Chưa chốt |
| HE_THONG_NGOAI | Cổng thanh toán trực tuyến (môi trường sandbox, API tạo giao dịch, callback kết quả, hoàn tiền); Dịch vụ gửi email (SMTP) |

## 4. Ràng buộc đặc thù của dự án

- Đăng nhập không được mô hình hoá thành use case (ghi đè P02 U-R01). Việc tác nhân đã đăng nhập chỉ ghi là tiền điều kiện của các use case cần xác thực (P04), không vẽ trên biểu đồ use case (P03).
