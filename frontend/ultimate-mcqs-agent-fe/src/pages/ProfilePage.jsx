import React, { useState, useEffect } from "react";
import api from "../services/api";
import { useAuth } from "../context/AuthContext";
import "./ProfilePage.css";

function ProfilePage() {
  const { user } = useAuth();

  // --- STATE ---
  const [isEditing, setIsEditing] = useState(false);
  const [originalData, setOriginalData] = useState({});
  const [profileData, setProfileData] = useState({
    full_name: "",
    email: "",
    phone_number: "",
    birth: "",
  });
  const [passwordData, setPasswordData] = useState({
    old_password: "",
    new_password: "",
    confirm_password: "",
  });

  const [isSavingProfile, setIsSavingProfile] = useState(false);
  const [isSavingPassword, setIsSavingPassword] = useState(false);
  const [profileMessage, setProfileMessage] = useState({ type: "", text: "" });
  const [passwordMessage, setPasswordMessage] = useState({
    type: "",
    text: "",
  });

  // --- 1. LOAD DATA ---
  useEffect(() => {
    if (user) {
      const data = {
        full_name: user.full_name || "",
        email: user.email || "",
        phone_number: user.phone_number || "",
        birth: user.birth ? user.birth.split("T")[0] : "",
      };
      setProfileData(data);
      setOriginalData(data);
    }
  }, [user]);

  // --- 2. VALIDATION (Giữ nguyên logic của bạn) ---
  const validateProfileInput = () => {
    const { full_name, email, phone_number, birth } = profileData;

    // 2.1. Kiểm tra Họ tên
    if (!full_name || full_name.trim().length < 2) {
      return "Họ tên phải có ít nhất 2 ký tự.";
    }

    // Nếu bạn muốn chặn các ký tự quá nguy hiểm (như < > để hack web) thì dùng dòng dưới.
    // Còn không thì cứ để người dùng nhập thoải mái.
    if (/[<>;]/.test(full_name)) {
      return "Họ tên không được chứa ký tự đặc biệt như < > ;";
    }

    // 2.2. Kiểm tra Email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!email || !emailRegex.test(email)) {
      return "Địa chỉ Email không hợp lệ.";
    }

    // 2.3. Kiểm tra SĐT
    if (phone_number) {
      const phoneRegex = /^(0)\d{9}$/;
      if (!phoneRegex.test(phone_number)) {
        return "Số điện thoại phải có 10 chữ số và bắt đầu bằng số 0.";
      }
    }

    // 2.4. Kiểm tra Ngày sinh
    if (birth) {
      const selectedDate = new Date(birth);
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      if (selectedDate > today) {
        return "Ngày sinh không được lớn hơn ngày hiện tại.";
      }
    }

    return null;
  };

  // --- 3. XỬ LÝ SỰ KIỆN ---
  const handleProfileChange = (e) => {
    const { name, value } = e.target;
    setProfileData({ ...profileData, [name]: value });
  };

  const handleSaveProfile = async (e) => {
    e.preventDefault();

    // Validate
    const errorMsg = validateProfileInput();
    if (errorMsg) {
      setProfileMessage({ type: "error", text: errorMsg });
      return;
    }

    setIsSavingProfile(true);
    setProfileMessage({ type: "", text: "" });

    try {
      // === SỬA LẠI: Dùng URLSearchParams để Backend nhận được ===
      const formData = new URLSearchParams();
      formData.append("full_name", profileData.full_name);
      formData.append("email", profileData.email);
      formData.append("phone_number", profileData.phone_number || ""); // Gửi rỗng nếu không có
      if (profileData.birth) {
        formData.append("birth", profileData.birth);
      }

      // Gọi API
      await api.put(`/users/${user.user_id}`, formData, {
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
      });

      setOriginalData(profileData);
      setIsEditing(false);
      setProfileMessage({
        type: "success",
        text: "Cập nhật thông tin thành công!",
      });

      // Reload để cập nhật Context (nếu cần thiết)
      setTimeout(() => window.location.reload(), 1000);
    } catch (err) {
      console.error(err);
      setProfileMessage({
        type: "error",
        text:
          "Lỗi cập nhật: " + (err.response?.data?.detail || "Không xác định"),
      });
    } finally {
      setIsSavingProfile(false);
    }
  };

  const handleCancelEdit = () => {
    setProfileData(originalData);
    setIsEditing(false);
    setProfileMessage({ type: "", text: "" });
  };

  const handlePasswordChange = (e) => {
    const { name, value } = e.target;
    setPasswordData({ ...passwordData, [name]: value });
  };

  const handleChangePasswordSubmit = async (e) => {
    e.preventDefault();

    if (passwordData.new_password.length < 6) {
      setPasswordMessage({
        type: "error",
        text: "Mật khẩu mới phải có ít nhất 6 ký tự.",
      });
      return;
    }

    if (passwordData.new_password !== passwordData.confirm_password) {
      setPasswordMessage({
        type: "error",
        text: "Mật khẩu xác nhận không khớp!",
      });
      return;
    }

    setIsSavingPassword(true);
    setPasswordMessage({ type: "", text: "" });

    try {
      // === SỬA LẠI: Dùng URLSearchParams ===
      const formData = new URLSearchParams();
      formData.append("old_password", passwordData.old_password);
      // Backend cũ dùng key là 'password' cho mật khẩu mới
      formData.append("password", passwordData.new_password);

      await api.put(`/users/${user.user_id}`, formData, {
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
      });

      setPasswordMessage({ type: "success", text: "Đổi mật khẩu thành công!" });
      setPasswordData({
        old_password: "",
        new_password: "",
        confirm_password: "",
      });
    } catch (err) {
      setPasswordMessage({
        type: "error",
        text: err.response?.data?.detail || "Lỗi đổi mật khẩu.",
      });
    } finally {
      setIsSavingPassword(false);
    }
  };

  // --- 4. GIAO DIỆN (Y HỆT CODE BẠN YÊU CẦU) ---
  return (
    <div className="profile-page-container">
      {/* === CARD 1: THÔNG TIN CÁ NHÂN === */}
      <div className="profile-card">
        <div className="card-header-custom">
          <h3>Thông tin cá nhân</h3>
        </div>

        <form onSubmit={handleSaveProfile}>
          <div className="form-row">
            <div className="form-group">
              <label className="info-label">Họ và tên</label>
              <input
                type="text"
                name="full_name"
                value={profileData.full_name}
                onChange={handleProfileChange}
                disabled={!isEditing}
                className="profile-input-field"
                placeholder="Chưa cập nhật"
              />
            </div>
            <div className="form-group">
              <label className="info-label">Ngày sinh</label>
              <input
                type="date"
                name="birth"
                value={profileData.birth}
                onChange={handleProfileChange}
                disabled={!isEditing}
                className="profile-input-field"
              />
            </div>
          </div>

          <div className="form-row">
            <div className="form-group">
              <label className="info-label">Email</label>
              <input
                type="email"
                name="email"
                value={profileData.email}
                onChange={handleProfileChange}
                disabled={!isEditing}
                className="profile-input-field"
                placeholder="Nhập email mới"
                required
              />
            </div>
            <div className="form-group">
              <label className="info-label">Số điện thoại</label>
              <input
                type="text"
                name="phone_number"
                value={profileData.phone_number}
                onChange={handleProfileChange}
                disabled={!isEditing}
                className="profile-input-field"
                placeholder="Chưa cập nhật"
                maxLength={10}
              />
            </div>
          </div>

          <div className="card-footer">
            <div style={{ flex: 1 }}>
              {profileMessage.text && (
                <span className={`message ${profileMessage.type}`}>
                  {profileMessage.text}
                </span>
              )}
            </div>

            <div className="edit-actions">
              {!isEditing ? (
                <button
                  type="button"
                  className="edit-button edit-mode"
                  onClick={(e) => {
                    e.preventDefault();
                    setIsEditing(true);
                  }}
                >
                  Chỉnh sửa
                </button>
              ) : (
                <>
                  <button
                    type="button"
                    className="edit-button cancel"
                    onClick={handleCancelEdit}
                  >
                    Hủy
                  </button>
                  <button
                    type="submit"
                    className="edit-button save"
                    disabled={isSavingProfile}
                  >
                    {isSavingProfile ? "Đang lưu..." : "Lưu thay đổi"}
                  </button>
                </>
              )}
            </div>
          </div>
        </form>
      </div>

      {/* === CARD 2: ĐỔI MẬT KHẨU === */}
      <div className="profile-card">
        <div className="card-header-custom">
          <h3>Đổi mật khẩu</h3>
        </div>
        <form onSubmit={handleChangePasswordSubmit}>
          <div className="form-group full-width-group">
            <label className="info-label">Mật khẩu cũ</label>
            <input
              type="password"
              name="old_password"
              value={passwordData.old_password}
              onChange={handlePasswordChange}
              required
              className="profile-input-field"
            />
          </div>
          <div className="form-group full-width-group">
            <label className="info-label">Mật khẩu mới</label>
            <input
              type="password"
              name="new_password"
              value={passwordData.new_password}
              onChange={handlePasswordChange}
              required
              className="profile-input-field"
              placeholder="Tối thiểu 6 ký tự"
            />
          </div>
          <div className="form-group full-width-group">
            <label className="info-label">Xác nhận mật khẩu</label>
            <input
              type="password"
              name="confirm_password"
              value={passwordData.confirm_password}
              onChange={handlePasswordChange}
              required
              className="profile-input-field"
            />
          </div>

          <div className="card-footer">
            <span className={`message ${passwordMessage.type}`}>
              {passwordMessage.text}
            </span>
            <button
              type="submit"
              className="edit-button save"
              disabled={isSavingPassword}
            >
              {isSavingPassword ? "Đang xử lý..." : "Đổi mật khẩu"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default ProfilePage;
