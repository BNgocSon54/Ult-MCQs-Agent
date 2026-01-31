import React, { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import api from "../services/api";

// === IMPORT FILE CSS ===
import "./LoginPage.css";

function LoginPage() {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");

  // State quản lý lỗi của từng ô input (để hiện viền đỏ)
  const [errors, setErrors] = useState({});
  // State quản lý lỗi chung từ Server (ví dụ: Sai pass, Lỗi mạng)
  const [serverError, setServerError] = useState("");

  const [isLoading, setIsLoading] = useState(false);

  const navigate = useNavigate();
  const { login } = useAuth();

  // --- HÀM KIỂM TRA RỖNG ---
  const validateInput = () => {
    let newErrors = {};
    let isValid = true;

    if (!username.trim()) {
      newErrors.username = "Vui lòng nhập tên đăng nhập.";
      isValid = false;
    }

    if (!password.trim()) {
      newErrors.password = "Vui lòng nhập mật khẩu.";
      isValid = false;
    }

    setErrors(newErrors);
    return isValid;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setServerError(""); // Reset lỗi server cũ

    // 1. Validate Client (Kiểm tra rỗng)
    if (!validateInput()) {
      return;
    }

    setIsLoading(true);

    try {
      const formData = new URLSearchParams();
      formData.append("username", username.trim());
      formData.append("password", password);

      const response = await api.post("/auth/login", formData, {
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
      });

      const { access_token } = response.data;

      // Lưu token vào Context
      login(access_token);

      // Chuyển hướng
      navigate("/dashboard/agent");
    } catch (err) {
      console.error("Login Error:", err);

      // 2. Xử lý lỗi từ Backend trả về
      if (err.response && err.response.data) {
        const detail = err.response.data.detail;

        if (Array.isArray(detail)) {
          // Lỗi thiếu trường (thường ít gặp vì đã validate ở trên)
          setServerError(detail[0].msg);
        } else {
          // Lỗi logic: "Sai tên đăng nhập hoặc mật khẩu" hoặc "Tài khoản bị khóa"
          setServerError(detail || "Đăng nhập thất bại.");
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
        <h2>Đăng nhập</h2>

        {/* Thêm noValidate để tắt bong bóng mặc định của trình duyệt */}
        <form onSubmit={handleSubmit} noValidate>
          {/* --- USERNAME --- */}
          <div className="form-group">
            <label htmlFor="username">Username:</label>
            <input
              id="username"
              type="text"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              placeholder="Nhập tên đăng nhập"
              disabled={isLoading}
              // Nếu có lỗi username -> Thêm class viền đỏ
              className={errors.username ? "input-error" : ""}
            />
            {/* Hiện dòng chữ đỏ bên dưới */}
            {errors.username && (
              <span className="field-error">{errors.username}</span>
            )}
          </div>

          {/* --- PASSWORD --- */}
          <div className="form-group">
            <label htmlFor="password">Password:</label>
            <input
              id="password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Nhập mật khẩu"
              disabled={isLoading}
              className={errors.password ? "input-error" : ""}
            />
            {errors.password && (
              <span className="field-error">{errors.password}</span>
            )}
          </div>

          {/* --- LỖI CHUNG TỪ SERVER --- */}
          {/* (Hiện ở dưới cùng vì lỗi này không thuộc về riêng ô nào cả để bảo mật) */}
          {serverError && <p className="error-message">{serverError}</p>}

          <button type="submit" className="login-button" disabled={isLoading}>
            {isLoading ? "Đang xử lý..." : "Đăng nhập"}
          </button>
        </form>

        <div style={{ textAlign: "right", marginTop: "10px" }}>
          <Link
            to="/forgot-password"
            style={{
              color: "#007bff",
              textDecoration: "none",
              fontSize: "0.9rem",
            }}
          >
            Quên mật khẩu?
          </Link>
        </div>

        <div className="register-link">
          Bạn chưa có tài khoản? <Link to="/register">Đăng ký ngay</Link>
        </div>
      </div>
    </div>
  );
}

export default LoginPage;
