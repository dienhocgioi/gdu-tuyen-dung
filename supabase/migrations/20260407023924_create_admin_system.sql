/*
  # Tạo hệ thống phân quyền admin

  1. Bảng mới
    - `admin_users`
      - `id` (uuid, primary key)
      - `email` (text, unique) - Email người dùng
      - `role` (text) - Vai trò: super_admin, editor, viewer
      - `created_at` (timestamptz) - Thời gian tạo
      - `created_by` (text) - Người tạo
      - `updated_at` (timestamptz) - Thời gian cập nhật
      - `is_active` (boolean) - Trạng thái hoạt động
    
    - `admin_audit_log`
      - `id` (uuid, primary key)
      - `admin_id` (uuid) - ID admin thực hiện
      - `action` (text) - Hành động thực hiện
      - `target_email` (text) - Email mục tiêu
      - `details` (jsonb) - Chi tiết hành động
      - `created_at` (timestamptz) - Thời gian

  2. Bảo mật
    - Bật RLS cho cả 2 bảng
    - Chỉ super_admin mới có quyền quản lý người dùng
    - Mọi người có thể xem thông tin của chính mình
    - Audit log chỉ super_admin mới xem được
*/

-- Tạo bảng admin_users
CREATE TABLE IF NOT EXISTS admin_users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  role text NOT NULL CHECK (role IN ('super_admin', 'editor', 'viewer')),
  created_at timestamptz DEFAULT now(),
  created_by text NOT NULL,
  updated_at timestamptz DEFAULT now(),
  is_active boolean DEFAULT true
);

-- Tạo bảng audit log
CREATE TABLE IF NOT EXISTS admin_audit_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id uuid REFERENCES admin_users(id),
  action text NOT NULL,
  target_email text,
  details jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now()
);

-- Bật RLS
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_audit_log ENABLE ROW LEVEL SECURITY;

-- Policies cho admin_users
CREATE POLICY "Anyone can view their own admin info"
  ON admin_users FOR SELECT
  TO authenticated
  USING (email = auth.jwt() ->> 'email');

CREATE POLICY "Super admins can view all admin users"
  ON admin_users FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admin_users
      WHERE email = auth.jwt() ->> 'email'
      AND role = 'super_admin'
      AND is_active = true
    )
  );

CREATE POLICY "Super admins can insert admin users"
  ON admin_users FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM admin_users
      WHERE email = auth.jwt() ->> 'email'
      AND role = 'super_admin'
      AND is_active = true
    )
  );

CREATE POLICY "Super admins can update admin users"
  ON admin_users FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admin_users
      WHERE email = auth.jwt() ->> 'email'
      AND role = 'super_admin'
      AND is_active = true
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM admin_users
      WHERE email = auth.jwt() ->> 'email'
      AND role = 'super_admin'
      AND is_active = true
    )
  );

CREATE POLICY "Super admins can delete admin users"
  ON admin_users FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admin_users
      WHERE email = auth.jwt() ->> 'email'
      AND role = 'super_admin'
      AND is_active = true
    )
    AND email != auth.jwt() ->> 'email'
  );

-- Policies cho audit_log
CREATE POLICY "Super admins can view audit log"
  ON admin_audit_log FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admin_users
      WHERE email = auth.jwt() ->> 'email'
      AND role = 'super_admin'
      AND is_active = true
    )
  );

CREATE POLICY "Super admins can insert audit log"
  ON admin_audit_log FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM admin_users
      WHERE email = auth.jwt() ->> 'email'
      AND role = 'super_admin'
      AND is_active = true
    )
  );

-- Thêm admin đầu tiên
INSERT INTO admin_users (email, role, created_by)
VALUES ('dienhocgioi.02@gmail.com', 'super_admin', 'bootstrap')
ON CONFLICT (email) DO UPDATE SET 
  role = 'super_admin',
  is_active = true,
  updated_at = now();

-- Tạo index để tăng tốc truy vấn
CREATE INDEX IF NOT EXISTS idx_admin_users_email ON admin_users(email);
CREATE INDEX IF NOT EXISTS idx_admin_users_role ON admin_users(role);
CREATE INDEX IF NOT EXISTS idx_audit_log_admin_id ON admin_audit_log(admin_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_created_at ON admin_audit_log(created_at DESC);