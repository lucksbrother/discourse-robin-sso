# Hwork SSO 插件 - 快速开始

## 🚀 5 分钟快速上手

### 1. 确认插件已安装

插件位置：
```
plugins/discourse-hwork-sso/
```

### 2. 启动 Discourse

```bash
cd /Users/robin/Work/hwork-bbs/discourse-2026.1.0-latest
bin/rails server
```

### 3. 测试 SSO 登录

#### 方式 1: 使用测试页面

访问：`http://localhost:3000/plugins/discourse-hwork-sso/test.html`

#### 方式 2: 直接访问 SSO URL

```
http://localhost:3000/hwork-sso?token=YOUR_JWT_TOKEN
```

#### 方式 3: 使用 curl 测试

```bash
curl -X GET "http://localhost:3000/hwork-sso?token=YOUR_JWT_TOKEN"
```

### 4. 验证登录

打开浏览器控制台：

```javascript
// 检查 Token
localStorage.getItem("hwork_system_token")

// 检查当前用户
fetch('/session/current.json')
  .then(r => r.json())
  .then(data => console.log(data.current_user))
```

### 5. 查看日志

```bash
tail -f log/development.log | grep "Hwork"
```

## 📋 配置选项

访问：管理后台 -> 设置 -> 插件 -> discourse-hwork-sso

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| hwork_sso_enabled | true | 启用/禁用插件 |
| hwork_api_url | https://pre-hwork.haier.net/gw/login/api/v2/get-user-info | API 地址 |
| hwork_cache_duration | 300 | 缓存时长（秒） |
| hwork_request_timeout | 5 | 请求超时（秒） |

## 🔧 集成到主系统

### JavaScript 示例

```javascript
// 获取 Token
const token = getMainSystemToken();

// 跳转到 Discourse SSO
window.location.href = `http://discourse.com/hwork-sso?token=${token}`;
```

### React 示例

```jsx
import { useEffect } from 'react';

function DiscourseSSO() {
  useEffect(() => {
    const token = getToken();
    if (token) {
      window.location.href = `http://discourse.com/hwork-sso?token=${token}`;
    }
  }, []);
  
  return <div>正在跳转到论坛...</div>;
}
```

### Vue 示例

```vue
<template>
  <div>正在跳转到论坛...</div>
</template>

<script>
export default {
  mounted() {
    const token = this.getToken();
    if (token) {
      window.location.href = `http://discourse.com/hwork-sso?token=${token}`;
    }
  }
}
</script>
```

## 🧪 测试清单

- [ ] 访问 SSO URL 能正常跳转
- [ ] Token 保存到 localStorage
- [ ] 用户自动创建/登录
- [ ] API 请求携带 X-System-Token header
- [ ] 缓存机制正常工作
- [ ] 错误处理正常

## 📊 工作流程

```
1. 主系统获取 JWT Token
   ↓
2. 跳转: http://discourse.com/hwork-sso?token=JWT
   ↓
3. 前端保存 token 到 localStorage
   ↓
4. 重定向到首页
   ↓
5. 所有 API 请求自动携带 X-System-Token
   ↓
6. 后端验证 token 并获取用户信息
   ↓
7. 自动创建/查找用户
   ↓
8. 认证完成 ✅
```

## 🐛 常见问题

### Q: Token 未保存？

**A:** 检查浏览器控制台是否有错误：
```javascript
localStorage.getItem("hwork_system_token")
```

### Q: 认证失败？

**A:** 查看 Discourse 日志：
```bash
tail -f log/development.log | grep "Hwork"
```

### Q: 用户未创建？

**A:** 检查 API 响应：
```bash
# Rails console
bin/rails c
User.where("username LIKE 'user_%'").last
```

### Q: 如何禁用插件？

**A:** 管理后台 -> 设置 -> 插件 -> discourse-hwork-sso -> hwork_sso_enabled = false

## 📚 更多文档

- [README.md](README.md) - 完整文档
- [MIGRATION.md](MIGRATION.md) - 迁移指南
- [Discourse 插件开发指南](https://meta.discourse.org/t/beginners-guide-to-creating-discourse-plugins/30515)

## 💡 提示

- 建议在开发环境先测试
- 生产环境使用 HTTPS
- 定期检查日志
- 根据需要调整缓存时长

## 🎉 完成！

现在你已经成功配置了 Hwork SSO 插件，可以开始使用了！
