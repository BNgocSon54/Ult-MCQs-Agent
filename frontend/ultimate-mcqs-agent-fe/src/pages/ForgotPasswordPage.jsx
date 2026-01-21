// src/pages/ForgotPasswordPage.jsx
import React, { useState } from "react";
import { Link } from "react-router-dom";
import api from "../services/api";
import "./LoginPage.css"; // Dùng chung giao diện với trang đăng nhập cho đẹp

function ForgotPasswordPage() {
  const [email, setEmail] = useState("");
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setMessage("");
    setError("");

    try {
      const formData = new URLSearchParams();
      formData.append("email", email);

      // Gọi API backend
      await api.post("/auth/forgot-password", formData, {
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
      });
      setMessage(
        "✅ Vui lòng kiểm tra email của bạn để lấy link đặt lại mật khẩu.",
      );
    } catch (err) {
      // Nếu lỗi thì báo lỗi, nhưng đôi khi backend trả về 200 dù email sai để bảo mật
      setError("Có lỗi xảy ra hoặc email không tồn tại.");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="login-page-container">
      <div className="login-form-container">
        <h2>Quên mật khẩu</h2>
        <p
          style={{
            textAlign: "center",
            marginBottom: "1.5rem",
            color: "#666",
            fontSize: "0.9rem",
          }}
        >
          Nhập địa chỉ email liên kết với tài khoản của bạn. Chúng tôi sẽ gửi
          link để bạn đặt lại mật khẩu.
        </p>

        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label>Email:</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              placeholder="nhap_email_cua_ban@example.com"
            />
          </div>

          {/* Hiển thị thông báo thành công hoặc lỗi */}
          {message && (
            <div
              style={{
                color: "green",
                textAlign: "center",
                marginBottom: "1rem",
                fontWeight: "bold",
              }}
            >
              {message}
            </div>
          )}
          {error && (
            <div className="error-message" style={{ marginBottom: "1rem" }}>
              {error}
            </div>
          )}

          <button type="submit" className="login-button" disabled={isLoading}>
            {isLoading ? "Đang gửi..." : "Gửi yêu cầu"}
          </button>
        </form>

        <div className="register-link" style={{ marginTop: "1.5rem" }}>
          <Link to="/login">← Quay lại đăng nhập</Link>
        </div>
      </div>
    </div>
  );
}

export default ForgotPasswordPage;
