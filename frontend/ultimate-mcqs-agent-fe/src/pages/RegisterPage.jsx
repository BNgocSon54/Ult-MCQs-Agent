import React, { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import api from "../services/api";

import "./LoginPage.css";

function RegisterPage() {
  const [username, setUsername] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");

  // State lưu danh sách lỗi của từng trường
  const [errors, setErrors] = useState({});
  // State lưu lỗi chung từ server (ví dụ: Lỗi kết nối)
  const [serverError, setServerError] = useState("");

  const [isLoading, setIsLoading] = useState(false);
  const navigate = useNavigate();

  const validateInput = () => {
    let newErrors = {};
    let isValid = true;

    // 1. Kiểm tra Username
    if (!username || username.trim().length < 2) {
      newErrors.username = "Username phải có ít nhất 2 ký tự.";
      isValid = false;
    } else {
      const nameRegex =
        /^[a-zA-Z0-9\sÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừửữựỳỵỷỹ]+$/;
      if (!nameRegex.test(username)) {
        newErrors.username = "Username không được chứa ký tự đặc biệt.";
        isValid = false;
      }
    }

    // 2. Kiểm tra Email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!email) {
      newErrors.email = "Email không được để trống.";
      isValid = false;
    } else if (!emailRegex.test(email)) {
      newErrors.email = "Email không đúng định dạng (thiếu @ hoặc domain).";
      isValid = false;
    }

    // 3. Kiểm tra Password
    if (!password || password.length < 6) {
      newErrors.password = "Mật khẩu phải có ít nhất 6 ký tự.";
      isValid = false;
    }

    // 4. Kiểm tra Confirm Password
    if (password !== confirmPassword) {
      newErrors.confirmPassword = "Mật khẩu xác nhận không khớp.";
      isValid = false;
    }

    setErrors(newErrors); // Cập nhật danh sách lỗi vào state
    return isValid;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setServerError(""); // Reset lỗi server cũ

    // BƯỚC 1: Validate tại Frontend
    const isValid = validateInput();
    if (!isValid) {
      return; // Dừng nếu có lỗi nhập liệu
    }

    setIsLoading(true);

    try {
      const formData = new URLSearchParams();
      formData.append("username", username);
      formData.append("email", email);
      formData.append("password", password);

      await api.post("/auth/register", formData, {
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
      });

      alert("Đăng ký thành công! Vui lòng đăng nhập.");
      navigate("/login");
    } catch (err) {
      console.error("Lỗi đăng ký:", err.response);

      if (err.response && err.response.data) {
        const detail = err.response.data.detail;
        if (Array.isArray(detail)) {
          // Lỗi validation từ FastAPI -> Gán vào lỗi chung hoặc xử lý riêng
          setServerError(`Lỗi dữ liệu: ${detail[0].msg}`);
        } else {
          // Ví dụ: Username đã tồn tại -> Gán vào serverError
          setServerError(detail || "Đăng ký thất bại.");
        }
      } else {
        setServerError("Lỗi kết nối đến máy chủ.");
      }
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="login-page-container">
      <div className="login-form-container">
        <h2>Đăng ký tài khoản</h2>

        {/* QUAN TRỌNG: noValidate để tắt bong bóng của trình duyệt */}
        <form onSubmit={handleSubmit} noValidate>
          {/* --- USERNAME --- */}
          <div className="form-group">
            <label htmlFor="username">Username:</label>
            <input
              id="username"
              type="text"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              placeholder="Nhập tên hiển thị"
              disabled={isLoading}
              // Nếu có lỗi ở username -> thêm class input-error (viền đỏ)
              className={errors.username ? "input-error" : ""}
            />
            {/* Hiển thị dòng thông báo lỗi đỏ bên dưới */}
            {errors.username && (
              <span className="field-error">{errors.username}</span>
            )}
          </div>

          {/* --- EMAIL --- */}
          <div className="form-group">
            <label htmlFor="email">Email:</label>
            <input
              id="email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="email@example.com"
              disabled={isLoading}
              className={errors.email ? "input-error" : ""}
            />
            {errors.email && (
              <span className="field-error">{errors.email}</span>
            )}
          </div>

          {/* --- PASSWORD --- */}
          <div className="form-group">
            <label htmlFor="password">Mật khẩu:</label>
            <input
              id="password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Tối thiểu 6 ký tự"
              disabled={isLoading}
              className={errors.password ? "input-error" : ""}
            />
            {errors.password && (
              <span className="field-error">{errors.password}</span>
            )}
          </div>

          {/* --- CONFIRM PASSWORD --- */}
          <div className="form-group">
            <label htmlFor="confirmPassword">Nhập lại mật khẩu:</label>
            <input
              id="confirmPassword"
              type="password"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              placeholder="Xác nhận mật khẩu"
              disabled={isLoading}
              className={errors.confirmPassword ? "input-error" : ""}
            />
            {errors.confirmPassword && (
              <span className="field-error">{errors.confirmPassword}</span>
            )}
          </div>

          {/* Lỗi chung từ Server (ví dụ: Trùng user, mất mạng) */}
          {serverError && <p className="error-message">{serverError}</p>}

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
