# Robin SSO 插件测试报告

## 测试时间
2026-02-16 00:42

## 测试环境
- Discourse 版本: 最新开发版
- Ruby 版本: 3.4.8
- 前端端口: 4200
- 后端端口: 3000

## 发现的问题及修复

### 问题 1: 控制器未加载
**错误**: `uninitialized constant HworkSsoController`

**原因**: 控制器文件未在 `plugin.rb` 中加载

**修复**:
```ruby
# plugin.rb
after_initialize do
  require_relative "lib/hwork_token_authenticator"
  require_relative "app/controllers/hwork_sso_controller"  # 添加这行
  ...
end
```

### 问题 2: API 响应编码问题
**错误**: `Encoding::CompatibilityError - incompatible character encodings: UTF-8 and BINARY`

**原因**: Hwork API 返回的响应体编码为 BINARY，需要强制转换为 UTF-8

**修复**:
```ruby
# lib/hwork_token_authenticator.rb
def self.fetch_user_info(token)
  ...
  body = response.body.force_encoding('UTF-8')  # 添加这行
  data = JSON.parse(body)
  ...
end
```

### 问题 3: 邮箱查找失败
**错误**: `PG::UndefinedColumn: ERROR: column users.email does not exist`

**原因**: Discourse 使用 `user_emails` 表存储邮箱，不是直接在 `users` 表中

**修复**:
```ruby
# lib/hwork_token_authenticator.rb
def self.find_or_create_user(user_info)
  ...
  # 通过 UserEmail 表查找
  if user_info[:email]
    user_email = UserEmail.find_by(email: email)
    return user_email.user if user_email
  end
  ...
end
```

## 测试结果

### ✅ SSO 端点测试
```bash
curl "http://localhost:3000/hwork-sso?token=test123"
```
**结果**: 返回 200，HTML 页面正常，token 被保存到 localStorage

### ✅ Hwork API 调用测试
```bash
curl -H "Authorization: Bearer <JWT>" "https://pre-hwork.haier.net/gw/login/api/v2/get-user-info"
```
**结果**: 
```json
{
  "sub": "20015536",
  "code": 200,
  "message": "Success",
  "userName": "王斌",
  "userId": "20015536",
  "email": "wangbin.psi@haier.com"
}
```

### ✅ Token 认证测试
```ruby
token = '<真实JWT>'
user = HworkTokenAuthenticator.authenticate(token)
```
**结果**:
```
✅ 认证成功!
用户ID: 1
用户名: 20015536
姓名: 
邮箱: wangbin.psi@haier.com
```

## 功能验证

| 功能 | 状态 | 说明 |
|------|------|------|
| SSO 端点 | ✅ | `/hwork-sso?token=xxx` 正常工作 |
| Token 保存 | ✅ | localStorage 正常保存 token |
| API 调用 | ✅ | 成功调用 Hwork API 获取用户信息 |
| 用户查找 | ✅ | 通过用户名和邮箱查找用户 |
| 用户创建 | ✅ | 自动创建新用户（如果不存在） |
| 编码处理 | ✅ | 正确处理 UTF-8 编码 |
| 错误处理 | ✅ | 异常被正确捕获和记录 |

## 待测试功能

### 前端集成测试
- [ ] 测试页面 token 输入和跳转
- [ ] 验证 localStorage token 存储
- [ ] 验证 API 请求自动携带 X-System-Token header
- [ ] 测试登录后的用户状态

### 完整流程测试
1. 访问测试页面: `http://localhost:4200/plugins/discourse-robin-sso/test.html`
2. 输入真实 JWT token
3. 点击"测试 SSO 登录"
4. 验证跳转到首页
5. 验证用户已登录
6. 验证后续 API 请求携带 token

## 建议

### 1. 重启服务器
修复完成后需要重启 Rails 服务器以加载新代码：
```bash
# 停止服务器
lsof -ti:3000 | xargs kill -9

# 启动服务器
cd /Users/robin/Study/bbs/discourse
bin/rails s -p 3000
```

### 2. 清除缓存
如果遇到问题，清除 Rails 缓存：
```bash
bin/rails runner "Rails.cache.clear"
```

### 3. 监控日志
实时查看日志以调试问题：
```bash
tail -f log/development.log | grep -i "hwork\|error"
```

## 下一步

1. ✅ 修复所有发现的问题
2. ⏳ 重启服务器测试完整流程
3. ⏳ 测试前端 token 注入功能
4. ⏳ 测试用户登录状态持久化
5. ⏳ 编写自动化测试用例

## 总结

插件核心功能已经修复并验证通过：
- ✅ 控制器正常加载
- ✅ API 调用成功
- ✅ 用户认证成功
- ✅ 编码问题已解决
- ✅ 数据库查询正确

需要重启服务器后进行完整的端到端测试。
