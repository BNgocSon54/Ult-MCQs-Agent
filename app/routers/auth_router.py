from fastapi import APIRouter, Form, HTTPException, Depends
from jose import jwt, JWTError
from passlib.context import CryptContext
from ..db import get_connection
from ..config import JWT_SECRET_KEY, JWT_ALGORITHM, JWT_EXPIRE_MINUTES, MAIL_USERNAME, MAIL_PASSWORD, MAIL_FROM, MAIL_PORT, MAIL_SERVER, REACT_BASE_URL
from datetime import datetime, timedelta
from typing import Optional
from fastapi import APIRouter, Form, HTTPException, Depends, Request 
from slowapi import Limiter 
from slowapi.util import get_remote_address
from fastapi import Depends
from fastapi.security import OAuth2PasswordBearer
from typing import Optional
from fastapi_mail import FastMail, MessageSchema, ConnectionConfig, MessageType
import secrets

limiter = Limiter(key_func=get_remote_address)

optional_oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl="/auth/login", 
    auto_error=False # <-- Không báo lỗi nếu không có token
)

mail_conf = ConnectionConfig(
    MAIL_USERNAME=MAIL_USERNAME,
    MAIL_PASSWORD=MAIL_PASSWORD,
    MAIL_FROM=MAIL_FROM,
    MAIL_PORT=MAIL_PORT,
    MAIL_SERVER=MAIL_SERVER,
    MAIL_STARTTLS=True,
    MAIL_SSL_TLS=False,
    USE_CREDENTIALS=True,
    VALIDATE_CERTS=True
)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

def get_current_user(token: str = Depends(oauth2_scheme)):
    try:
        payload = jwt.decode(token, JWT_SECRET_KEY, algorithms=[JWT_ALGORITHM])
        user_id = payload.get("user_id")
        
        if user_id is None:
             raise HTTPException(status_code=401, detail="Invalid token (no user_id).")

        conn = get_connection()
        cur = conn.cursor(dictionary=True)
        
        # === LẤY TẤT CẢ THÔNG TIN MỚI TỪ DATABASE ===
        cur.execute("""
            SELECT user_id, username, email, full_name, phone_number, birth, is_active, is_admin
            FROM Users 
            WHERE user_id=%s
        """, (user_id,))
        user = cur.fetchone() # user bây giờ là full profile từ DB
        cur.close(); conn.close()
        # === KẾT THÚC SỬA ===

        if not user:
            raise HTTPException(status_code=401, detail="User not found.")
        if user["is_active"] == 0:
            raise HTTPException(status_code=403, detail="Account disabled.")

        # Trả về TOÀN BỘ thông tin user lấy từ DB
        return user
        
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid or expired token.")

router = APIRouter(prefix="/auth", tags=["Auth"])
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=JWT_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, JWT_SECRET_KEY, algorithm=JWT_ALGORITHM)

def get_optional_current_user(token: Optional[str] = Depends(optional_oauth2_scheme)):
    """
    Cố gắng xác thực người dùng.
    Trả về `user` dict nếu token hợp lệ.
    Trả về `None` nếu không có token hoặc token không hợp lệ.
    """
    if not token:
        return None
    
    try:
        payload = jwt.decode(token, JWT_SECRET_KEY, algorithms=[JWT_ALGORITHM])
        user_id = payload.get("user_id")
        username = payload.get("sub")

        if user_id is None:
            return None 

        conn = get_connection()
        cur = conn.cursor(dictionary=True)
        # SỬA LỖI ? -> %s
        cur.execute("SELECT is_active FROM Users WHERE user_id=%s", (user_id,))
        user_db = cur.fetchone()
        cur.close(); conn.close()

        if not user_db or user_db["is_active"] == 0:
            return None 

        return {"username": username, "user_id": user_id, "is_admin": payload.get("is_admin", 0)}

    except JWTError:
        return None
    
@router.post("/forgot-password")
async def forgot_password(email: str = Form(...)):
    conn = get_connection()
    cur = conn.cursor(dictionary=True)
    try:
        # 1. Kiểm tra email có tồn tại không
        cur.execute("SELECT user_id, username FROM Users WHERE email = %s", (email,))
        user = cur.fetchone()
        if not user:
            # Vì bảo mật, không nên báo lỗi "Email không tồn tại", cứ báo thành công giả
            return {"message": "Nếu email tồn tại, chúng tôi đã gửi link reset."}

        # 2. Tạo Token ngẫu nhiên & Hạn sử dụng (15 phút)
        token = secrets.token_urlsafe(32)
        expires = datetime.now() + timedelta(minutes=15)

        # 3. Lưu vào DB
        cur.execute("""
            UPDATE Users SET reset_token = %s, reset_token_expires = %s WHERE user_id = %s
        """, (token, expires, user["user_id"]))
        conn.commit()

        # 4. Gửi Email
        reset_link = f"{REACT_BASE_URL}/reset-password?token={token}"
        
        html = f"""
        <p>Xin chào {user['username']},</p>
        <p>Bạn đã yêu cầu đặt lại mật khẩu. Vui lòng bấm vào link dưới đây:</p>
        <a href="{reset_link}" style="padding: 10px 20px; background-color: #007bff; color: white; text-decoration: none; border-radius: 5px;">Đặt lại mật khẩu</a>
        <p>Link này sẽ hết hạn sau 15 phút.</p>
        """

        message = MessageSchema(
            subject="Ultimate MCQs - Đặt lại mật khẩu",
            recipients=[email],
            body=html,
            subtype=MessageType.html
        )

        fm = FastMail(mail_conf)
        await fm.send_message(message)

        return {"message": "Đã gửi email hướng dẫn đặt lại mật khẩu."}
    
    except Exception as e:
        print(f"Mail Error: {e}")
        raise HTTPException(status_code=500, detail="Lỗi khi gửi email.")
    finally:
        cur.close(); conn.close()

# --- API 2: Thực hiện đổi mật khẩu mới ---
@router.post("/reset-password")
async def reset_password(token: str = Form(...), new_password: str = Form(...)):
    conn = get_connection()
    cur = conn.cursor(dictionary=True)
    try:
        # 1. Tìm user có token này và chưa hết hạn
        cur.execute("""
            SELECT user_id FROM Users 
            WHERE reset_token = %s AND reset_token_expires > NOW()
        """, (token,))
        user = cur.fetchone()

        if not user:
            raise HTTPException(status_code=400, detail="Link không hợp lệ hoặc đã hết hạn.")

        # 2. Hash mật khẩu mới & Xóa token
        hashed_password = hash_password(new_password)
        cur.execute("""
            UPDATE Users 
            SET password_hash = %s, reset_token = NULL, reset_token_expires = NULL 
            WHERE user_id = %s
        """, (hashed_password, user["user_id"]))
        conn.commit()

        return {"message": "Đổi mật khẩu thành công. Hãy đăng nhập lại."}
    finally:
        cur.close(); conn.close()

@router.post("/register")
@limiter.limit("5/minute")
def register(request: Request, username: str = Form(...), email: str = Form(...), password: str = Form(...)):
    conn = get_connection()
    cur = conn.cursor()
    # SỬA LỖI ? -> %s
    cur.execute("SELECT 1 FROM Users WHERE username=%s OR email=%s", (username, email))
    if cur.fetchone():
        raise HTTPException(status_code=400, detail="Username hoặc email đã tồn tại")
    hashed = hash_password(password)
    # SỬA LỖI ? -> %s
    cur.execute("INSERT INTO Users (username, email, password_hash, is_active) VALUES (%s, %s, %s, 1)",
                (username, email, hashed))
    conn.commit()
    return {"message": "Đăng ký thành công"}

@router.post("/login")
@limiter.limit("5/minute")
def login(request: Request, username: str = Form(...), password: str = Form(...)):
    conn = get_connection()
    cur = conn.cursor(dictionary=True)
    # SỬA LỖI ? -> %s
    cur.execute("SELECT * FROM Users WHERE username=%s", (username,))
    user = cur.fetchone()
    if not user or not verify_password(password, user["password_hash"]):
        raise HTTPException(status_code=401, detail="Sai tên đăng nhập hoặc mật khẩu")
    token = create_access_token({"sub": user["username"], "user_id": user["user_id"], "is_admin": user.get("is_admin", 0)})
    return {"access_token": token, "token_type": "bearer"}