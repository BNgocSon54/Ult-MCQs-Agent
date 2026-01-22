import React, { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import api from "../services/api";

import "./LoginPage.css";

function RegisterPage() {
  const [username, setUsername] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");

  const [error, setError] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const navigate = useNavigate();

  const validateInput = () => {
    if (!username || username.trim().length < 2) {
      return "Username phải có ít nhất 2 ký tự.";
    }
    // Regex: Chỉ cho phép chữ (Việt/Anh), số và khoảng trắng. Cấm ký tự lạ như < > / @
    const nameRegex =
      /^[a-zA-Z0-9\sÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừửữựỳỵỷỹ]+$/;
    if (!nameRegex.test(username)) {
      return "Username không được chứa ký tự đặc biệt.";
    }

    // 2. Kiểm tra Email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return "Địa chỉ Email không hợp lệ.";
    }

    // 3. Kiểm tra độ dài mật khẩu
    if (password.length < 6) {
      return "Mật khẩu phải có ít nhất 6 ký tự.";
    }

    // 4. Kiểm tra khớp mật khẩu
    if (password !== confirmPassword) {
      return "Mật khẩu xác nhận không khớp.";
    }

    return null; // Không có lỗi
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");

    // BƯỚC 1: Validate tại Frontend
    const validationError = validateInput();
    if (validationError) {
      setError(validationError);
      return;
    }

    setIsLoading(true);

    try {
      // BƯỚC 2: Chuẩn bị dữ liệu gửi đi (Format x-www-form-urlencoded)
      const formData = new URLSearchParams();
      formData.append("username", username);
      formData.append("email", email);
      formData.append("password", password);
      // Lưu ý: Không gửi confirmPassword lên server

      // BƯỚC 3: Gọi API
      await api.post("/auth/register", formData, {
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
      });

      alert("Đăng ký thành công! Vui lòng đăng nhập.");
      navigate("/login");
    } catch (err) {
      console.error("Lỗi đăng ký:", err.response); // Log để debug

      // Xử lý hiển thị lỗi từ Backend (Tránh lỗi trắng màn hình)
      if (err.response && err.response.data) {
        const detail = err.response.data.detail;
        if (Array.isArray(detail)) {
          // Nếu lỗi là mảng (FastAPI validation error)
          setError(`Lỗi dữ liệu: ${detail[0].msg}`);
        } else {
          // Nếu lỗi là chuỗi thông thường (VD: Username đã tồn tại)
          setError(detail || "Đăng ký thất bại.");
        }
      } else {
        setError("Lỗi kết nối đến máy chủ.");
      }
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="login-page-container">
      <div className="login-form-container">
        <h2>Đăng ký tài khoản</h2>
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label htmlFor="username">Username:</label>
            <input
              id="username"
              type="text"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              required
              placeholder="Nhập tên hiển thị"
              disabled={isLoading}
            />
          </div>

          <div className="form-group">
            <label htmlFor="email">Email:</label>
            <input
              id="email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              placeholder="email@example.com"
              disabled={isLoading}
            />
          </div>

          <div className="form-group">
            <label htmlFor="password">Mật khẩu:</label>
            <input
              id="password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              placeholder="Tối thiểu 6 ký tự"
              disabled={isLoading}
            />
          </div>

          {/* Ô Nhập lại mật khẩu mới thêm */}
          <div className="form-group">
            <label htmlFor="confirmPassword">Nhập lại mật khẩu:</label>
            <input
              id="confirmPassword"
              type="password"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              required
              placeholder="Xác nhận mật khẩu"
              disabled={isLoading}
            />
          </div>

          {error && <p className="error-message">{error}</p>}

          <button type="submit" className="login-button" disabled={isLoading}>
            {isLoading ? "Đang xử lý..." : "Đăng ký"}
          </button>
        </form>

        <div className="login-link">
          Đã có tài khoản? <Link to="/login">Đăng nhập</Link>
        </div>
      </div>
    </div>
  );
}

export default RegisterPage;
