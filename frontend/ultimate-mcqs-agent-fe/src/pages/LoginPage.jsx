import React, { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import api from "../services/api";

// === IMPORT FILE CSS ===
import "./LoginPage.css";

function LoginPage() {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  // 1. Thêm trạng thái Loading để khóa nút khi đang gửi request
  const [isLoading, setIsLoading] = useState(false);

  const navigate = useNavigate();
  const { login } = useAuth();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");

    // 2. Validation phía Client: Kiểm tra rỗng trước khi gửi
    if (!username.trim() || !password.trim()) {
      setError("Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu.");
      return;
    }

    setIsLoading(true); // Bắt đầu Loading -> Khóa nút

    try {
      const formData = new URLSearchParams();
      formData.append("username", username);
      formData.append("password", password);

      const response = await api.post("/auth/login", formData, {
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
      });

      const { access_token } = response.data;

      // Lưu token vào Context
      login(access_token);

      // Chuyển hướng (Đảm bảo đường dẫn này đúng với router của bạn)
      navigate("/dashboard/agent");
    } catch (err) {
      console.error("Login Error:", err); // Log để debug nếu cần

      // 3. Xử lý lỗi thông minh từ Backend
      if (err.response && err.response.data) {
        const detail = err.response.data.detail;

        if (Array.isArray(detail)) {
          // Lỗi Validation từ FastAPI (VD: thiếu trường)
          setError(detail[0].msg);
        } else {
          // Lỗi Logic (VD: Sai pass, Tài khoản bị khóa)
          // Backend của bạn trả về: "Sai tên đăng nhập hoặc mật khẩu" hoặc "Account disabled."
          setError(detail || "Đăng nhập thất bại.");
        }
      } else {
        setError("Lỗi kết nối đến máy chủ.");
      }
    } finally {
      setIsLoading(false); // Kết thúc Loading -> Mở khóa nút
    }
  };

  return (
    <div className="login-page-container">
      <div className="login-form-container">
        <h2>Đăng nhập</h2>
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label htmlFor="username">Username:</label>
            <input
              id="username"
              type="text"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              required
              disabled={isLoading} // Khóa khi đang tải
              placeholder="Nhập tên đăng nhập"
            />
          </div>

          <div className="form-group">
            <label htmlFor="password">Password:</label>
            <input
              id="password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              disabled={isLoading} // Khóa khi đang tải
              placeholder="Nhập mật khẩu"
            />
          </div>

          {error && <p className="error-message">{error}</p>}

          <button
            type="submit"
            className="login-button"
            disabled={isLoading} // Khóa nút submit
          >
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
