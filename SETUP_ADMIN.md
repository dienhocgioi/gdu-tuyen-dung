# Hướng dẫn cài đặt hệ thống phân quyền

## 1. Cấu hình Supabase

1. Tạo file `.env` trong thư mục gốc:
```bash
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
```

2. Database migrations đã được apply tự động tạo các bảng:
   - `admin_users`: Quản lý người dùng và vai trò
   - `admin_audit_log`: Lưu lịch sử thay đổi phân quyền

## 2. Tạo admin đầu tiên (Bootstrap)

### Cách 1: Qua Console Browser

Mở Console của trình duyệt và chạy:

```javascript
// Import function
const { supabase } = await import('/src/lib/supabase.ts');

// Thêm admin đầu tiên
const { data, error } = await supabase
  .from('admin_users')
  .insert([{
    email: 'your.email@giadinh.edu.vn',
    role: 'super_admin',
    created_by: 'bootstrap'
  }])
  .select()
  .single();

console.log(data, error);
```

### Cách 2: Qua SQL trong Supabase Dashboard

1. Truy cập Supabase Dashboard > SQL Editor
2. Chạy query:

```sql
INSERT INTO admin_users (email, role, created_by)
VALUES ('your.email@giadinh.edu.vn', 'super_admin', 'bootstrap');
```

## 3. Các vai trò (Roles)

### Super Admin (super_admin)
- Toàn quyền quản lý hệ thống
- Thêm/sửa/xóa vị trí tuyển dụng
- Quản lý danh sách người dùng và phân quyền
- Xem tất cả thông tin

### Editor (editor)
- Thêm vị trí tuyển dụng mới
- Đăng bài tuyển dụng
- Xem danh sách ứng viên
- KHÔNG thể xóa vị trí hoặc quản lý người dùng

### Viewer (viewer)
- Chỉ xem danh sách vị trí tuyển dụng
- Xem danh sách ứng viên
- KHÔNG có quyền chỉnh sửa

## 4. Quy trình phân quyền

1. Super Admin đăng nhập vào hệ thống
2. Truy cập tab "Phân quyền"
3. Nhấn "Thêm người dùng"
4. Nhập email và chọn vai trò
5. Người dùng mới có thể đăng nhập bằng email đã được cấp quyền

## 5. Bảo mật

- Email phải được thêm vào database trước khi đăng nhập
- Row Level Security (RLS) đã được bật
- Audit log ghi lại tất cả thay đổi phân quyền
- Không thể tự xóa chính mình khỏi hệ thống

## 6. Kiểm tra quyền

Sau khi đăng nhập, hệ thống sẽ tự động:
- Kiểm tra email trong database
- Load vai trò và quyền hạn
- Hiển thị/ẩn các chức năng theo quyền
- Chặn các thao tác không được phép

## 7. Troubleshooting

### Không thể đăng nhập
- Kiểm tra email đã được thêm vào database chưa
- Kiểm tra kết nối Supabase (.env)

### Không thấy tab Phân quyền
- Chỉ super_admin mới thấy tab này
- Kiểm tra vai trò trong database

### Không thể thêm/sửa/xóa vị trí
- Viewer không có quyền này
- Editor có thể thêm nhưng không thể xóa
- Chỉ super_admin mới có toàn quyền
