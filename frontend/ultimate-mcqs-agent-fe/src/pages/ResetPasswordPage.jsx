// src/pages/ResetPasswordPage.jsx
import React, { useState } from "react";
import { useNavigate, useSearchParams } from "react-router-dom";
import api from "../services/api";
import "./LoginPage.css";

function ResetPasswordPage() {
  const [searchParams] = useSearchParams();
  const token = searchParams.get("token"); // Lấy mã token từ trên thanh địa chỉ
  const navigate = useNavigate();

  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [error, setError] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");

    if (password !== confirmPassword) {
      setError("Mật khẩu xác nhận không khớp.");
      return;
    }

    setIsLoading(true);
    try {
      const formData = new URLSearchParams();
      formData.append("token", token);
      formData.append("new_password", password);

      await api.post("/auth/reset-password", formData, {
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
      });

      alert(
        "🎉 Đổi mật khẩu thành công! Bạn sẽ được chuyển về trang đăng nhập.",
      );
      navigate("/login");
    } catch (err) {
      setError(
        err.response?.data?.detail || "Link đã hết hạn hoặc không hợp lệ.",
      );
    } finally {
      setIsLoading(false);
    }
  };

  // Nếu không có token trên URL thì báo lỗi luôn
  if (!token)
    return (
      <div className="login-page-container">
        <div className="login-form-container" style={{ textAlign: "center" }}>
          <p style={{ color: "red" }}>Đường dẫn không hợp lệ (Thiếu token).</p>
        </div>
      </div>
    );

  return (
    <div className="login-page-container">
      <div className="login-form-container">
        <h2>Đặt lại mật khẩu</h2>
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label>Mật khẩu mới:</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              minLength="5"
              placeholder="Nhập mật khẩu mới"
            />
          </div>
          <div className="form-group">
            <label>Xác nhận mật khẩu:</label>
            <input
              type="password"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              required
              placeholder="Nhập lại mật khẩu mới"
            />
          </div>

          {error && <p className="error-message">{error}</p>}

          <button type="submit" className="login-button" disabled={isLoading}>
            {isLoading ? "Đang lưu..." : "Lưu mật khẩu mới"}
          </button>
        </form>
      </div>
    </div>
  );
}

export default ResetPasswordPage;
