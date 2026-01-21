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

  // --- 1. LOAD DATA (GIỮ NGUYÊN NHƯ FILE CŨ CỦA BẠN) ---
  useEffect(() => {
    if (user) {
      const data = {
        full_name: user.full_name || "",
        email: user.email || "",
        phone_number: user.phone_number || "",
        // Xử lý ngày sinh an toàn nếu null
        birth: user.birth ? user.birth.split("T")[0] : "",
      };
      setProfileData(data);
      setOriginalData(data);
    }
  }, [user]);

  // --- 2. HÀM KIỂM TRA DỮ LIỆU (VALIDATION MỚI) ---
  const validateProfileInput = () => {
    const { full_name, email, phone_number, birth } = profileData;

    // 2.1. Kiểm tra Họ tên (Chống XSS cơ bản & Ký tự lạ)
    if (!full_name || full_name.trim().length < 2) {
      return "Họ tên phải có ít nhất 2 ký tự.";
    }
    // Regex: Chỉ chấp nhận chữ cái (bao gồm tiếng Việt) và khoảng trắng.
    // Ngăn chặn các ký tự như < > / \ (thường dùng trong XSS/SQLi)
    const nameRegex =
      /^[a-zA-ZÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừửữựỳỵỷỹ\s]+$/;
    if (!nameRegex.test(full_name)) {
      return "Họ tên không được chứa số hoặc ký tự đặc biệt.";
    }

    // 2.2. Kiểm tra Email (Đúng định dạng)
    // Regex email cơ bản
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!email || !emailRegex.test(email)) {
      return "Địa chỉ Email không hợp lệ.";
    }

    // 2.3. Kiểm tra Số điện thoại (VN: 10 số, bắt đầu bằng 0)
    if (phone_number) {
      const phoneRegex = /^(0)\d{9}$/;
      if (!phoneRegex.test(phone_number)) {
        return "Số điện thoại phải có 10 chữ số và bắt đầu bằng số 0.";
      }
    }

    // 2.4. Kiểm tra Ngày sinh (Không được lớn hơn hiện tại)
    if (birth) {
      const selectedDate = new Date(birth);
      const today = new Date();
      // Reset giờ về 0 để so sánh ngày chuẩn xác
      today.setHours(0, 0, 0, 0);
      if (selectedDate > today) {
        return "Ngày sinh không được lớn hơn ngày hiện tại.";
      }
    }

    return null; // Không có lỗi
  };

  // --- 3. XỬ LÝ SỰ KIỆN ---
  const handleProfileChange = (e) => {
    const { name, value } = e.target;
    setProfileData({ ...profileData, [name]: value });
  };

  const handleSaveProfile = async (e) => {
    e.preventDefault();

    // ==> BƯỚC KIỂM TRA DỮ LIỆU Ở ĐÂY <==
    const errorMsg = validateProfileInput();
    if (errorMsg) {
      setProfileMessage({ type: "error", text: errorMsg });
      return; // Dừng lại nếu có lỗi
    }

    setIsSavingProfile(true);
    setProfileMessage({ type: "", text: "" });
    try {
      await api.put(`/users/${user.user_id}`, profileData);
      setOriginalData(profileData);
      setIsEditing(false);
      setProfileMessage({
        type: "success",
        text: "Cập nhật thông tin thành công!",
      });
    } catch (err) {
      setProfileMessage({
        type: "error",
        text: "Lỗi cập nhật: " + (err.response?.data?.detail || err.message),
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

    // ==> THÊM KIỂM TRA ĐỘ DÀI MẬT KHẨU <==
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
      await api.put(`/users/${user.user_id}/password`, {
        old_password: passwordData.old_password,
        new_password: passwordData.new_password,
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

  // --- 4. GIAO DIỆN (GIỮ NGUYÊN) ---
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
                maxLength={10} // Giới hạn nhập 10 ký tự ngay trên input
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
            <label>Mật khẩu cũ</label>
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
            <label>Mật khẩu mới</label>
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
            <label>Xác nhận mật khẩu</label>
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
