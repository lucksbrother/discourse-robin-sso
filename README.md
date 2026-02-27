# Discourse Hwork SSO Plugin

Hwork 主系统 SSO 集成插件，支持通过 JWT Token 实现单点登录。

## 🎉 新功能：Cookie 自动登录（v2.0）

**更安全的登录方式**：无需在 URL 中传递 token，通过共享 Cookie + 专用登录页面实现自动登录。

### 快速开始

1. **主系统设置 Cookie 并跳转**：
```javascript
// 登录成功后
const env = import.meta.env.VITE_NODE_ENV; // test/staging/production
const cookieNames = {
  test: 'hwork_token_test',
  staging: 'hwork_token_pre',
  production: 'hwork_token_prod'
};

document.cookie = `${cookieNames[env]}=${token}; domain=.yourdomain.com; path=/; max-age=7200; SameSite=Lax; Secure`;
window.location.href = 'https://forum.yourdomain.com/hwork-sso-cookie';
```

2. **用户自动登录**：访问登录页面后自动完成认证并跳转！

📖 详细配置：[COOKIE_AUTO_LOGIN.md](./COOKIE_AUTO_LOGIN.md)

---

## 功能特性

- ✅ **Cookie 自动登录**（推荐）- 安全、无感知
- ✅ **URL 跳转登录**（兼容）- 支持旧方式
- ✅ JWT Token 认证
- ✅ 自动用户创建/查找
- ✅ Token 缓存机制（5分钟）
- ✅ 与现有认证兼容

## 安装

插件已集成到 Discourse，无需额外安装。

## 配置

在 Discourse 管理后台 -> 设置 -> 插件 -> discourse-hwork-sso：

- `hwork_sso_enabled`: 启用/禁用插件（默认：true）
- `hwork_api_url`: Hwork API 地址
- `hwork_cache_duration`: Token 缓存时长（秒，默认：300）
- `hwork_request_timeout`: API 请求超时（秒，默认：5）

## 使用方法

### 1. SSO 登录

从主系统跳转到 Discourse：

```
http://discourse.com/hwork-sso?token=YOUR_JWT_TOKEN
```

### 2. 集成示例

#### JavaScript
```javascript
const token = getMainSystemToken();
window.location.href = `http://discourse.com/hwork-sso?token=${token}`;
```

#### React
```jsx
function DiscourseSSO() {
  useEffect(() => {
    const token = getToken();
    window.location.href = `http://discourse.com/hwork-sso?token=${token}`;
  }, []);
  return <div>正在登录...</div>;
}
```

## 工作流程

```
主系统登录 → 获取 JWT Token → 跳转 /hwork-sso?token=JWT
  ↓
前端保存 token 到 localStorage
  ↓
重定向到首页
  ↓
所有 API 请求自动携带 X-System-Token header
  ↓
后端验证 token → 获取用户信息 → 自动创建/查找用户
  ↓
认证完成
```

## API 接口

### Hwork 主系统接口

- **URL**: `https://pre-hwork.haier.net/gw/login/api/v2/get-user-info`
- **Method**: GET
- **Header**: `Authorization: Bearer <JWT>`
- **Response**:
```json
{
  "code": 200,
  "message": "Success",
  "userName": "王斌",
  "userId": "20015536",
  "email": "wangbin.psi@haier.com"
}
```

## 用户映射

| 主系统 | Discourse |
|--------|-----------|
| userId: 20015536 | username: user_20015536 |
| userName: 王斌 | name: 王斌 |
| email: wangbin.psi@haier.com | email: wangbin.psi@haier.com |

## 安全特性

- HTTPS 加密通信
- Token 实时验证
- 5 分钟缓存减少主系统压力
- 5 秒超时保护
- 错误日志记录

## 故障排查

### Token 未保存
```javascript
localStorage.getItem("hwork_system_token")
```

### 请求未携带 Token
打开浏览器 Network 标签，检查请求 headers 中的 `X-System-Token`

### 认证失败
查看 Discourse 日志：`log/production.log` 或 `log/development.log`

## 开发

### 文件结构
```
discourse-hwork-sso/
├── plugin.rb                           # 插件主文件
├── lib/
│   └── hwork_token_current_user_provider.rb  # 认证提供者
├── app/
│   └── controllers/
│       └── hwork_sso_controller.rb     # SSO 控制器
├── assets/
│   └── javascripts/
│       └── discourse/
│           └── initializers/
│               └── hwork-sso.js        # 前端初始化器
└── config/
    ├── settings.yml                    # 配置
    └── locales/
        ├── server.en.yml               # 英文
        └── server.zh_CN.yml            # 中文
```

## License

MIT
