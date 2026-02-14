# Hwork SSO 插件化迁移指南

## 概述

已将之前的 Hwork SSO 功能改造为标准的 Discourse 插件形式。

## 改造内容

### 1. 后端改造

**之前的实现：**
- `lib/auth/custom_token_current_user_provider.rb` - 全局认证提供者
- `config/initializers/010-custom_token_auth.rb` - 全局初始化配置

**插件化后：**
- `plugins/discourse-hwork-sso/lib/hwork_token_current_user_provider.rb` - 插件内认证提供者
- `plugins/discourse-hwork-sso/plugin.rb` - 插件主文件，包含初始化逻辑

### 2. 前端改造

**之前的实现：**
- `frontend/discourse/app/routes/hwork-sso.js` - 全局路由
- `frontend/discourse/app/lib/ajax.js` - 修改核心文件

**插件化后：**
- `plugins/discourse-hwork-sso/app/controllers/hwork_sso_controller.rb` - 插件控制器
- `plugins/discourse-hwork-sso/assets/javascripts/discourse/initializers/hwork-sso.js` - 插件初始化器

### 3. 配置改造

**之前的实现：**
- 硬编码配置

**插件化后：**
- `plugins/discourse-hwork-sso/config/settings.yml` - 可配置的设置
- 支持管理后台动态配置

## 插件结构

```
plugins/discourse-hwork-sso/
├── plugin.rb                                    # 插件入口
├── README.md                                    # 插件文档
├── lib/
│   └── hwork_token_current_user_provider.rb    # 认证提供者
├── app/
│   └── controllers/
│       └── hwork_sso_controller.rb             # SSO 控制器
├── assets/
│   └── javascripts/
│       └── discourse/
│           └── initializers/
│               └── hwork-sso.js                # Ajax 拦截器
└── config/
    ├── settings.yml                            # 插件配置
    └── locales/
        ├── server.en.yml                       # 英文翻译
        └── server.zh_CN.yml                    # 中文翻译
```

## 优势

### 1. 模块化
- 所有代码集中在插件目录
- 不修改 Discourse 核心代码
- 易于维护和升级

### 2. 可配置
- 管理后台可视化配置
- 支持动态启用/禁用
- 配置持久化到数据库

### 3. 标准化
- 遵循 Discourse 插件规范
- 支持多语言
- 完整的文档

### 4. 可移植
- 可以轻松迁移到其他 Discourse 实例
- 可以打包分发
- 可以版本管理

## 迁移步骤

### 1. 清理旧代码（可选）

如果要完全移除旧的实现：

```bash
# 删除旧的全局文件
rm lib/auth/custom_token_current_user_provider.rb
rm config/initializers/010-custom_token_auth.rb
rm frontend/discourse/app/routes/hwork-sso.js
rm frontend/discourse/app/templates/hwork-sso.gjs

# 恢复被修改的核心文件
git checkout frontend/discourse/app/lib/ajax.js
git checkout frontend/discourse/app/routes/app-route-map.js
```

### 2. 启用插件

插件已自动启用（`hwork_sso_enabled: true`）

### 3. 配置插件

访问：管理后台 -> 设置 -> 插件 -> discourse-hwork-sso

可配置项：
- `hwork_sso_enabled`: 启用/禁用
- `hwork_api_url`: API 地址
- `hwork_cache_duration`: 缓存时长
- `hwork_request_timeout`: 请求超时

### 4. 重启 Discourse

```bash
cd /Users/robin/Work/hwork-bbs/discourse-2026.1.0-latest
bin/rails restart
```

## 测试

### 1. 测试 SSO 登录

```
http://localhost:3000/hwork-sso?token=YOUR_JWT_TOKEN
```

### 2. 验证 Token 注入

打开浏览器控制台：
```javascript
// 检查 localStorage
localStorage.getItem("hwork_system_token")

// 检查 API 请求
// Network 标签 -> 查看请求 Headers -> X-System-Token
```

### 3. 验证用户创建

```bash
# Rails console
cd /Users/robin/Work/hwork-bbs/discourse-2026.1.0-latest
bin/rails c

# 查询用户
User.where("username LIKE 'user_%'")
```

## 兼容性

- ✅ 与现有认证系统兼容
- ✅ 不影响其他登录方式
- ✅ 可以与其他插件共存
- ✅ 支持 Discourse 2026.1.0+

## 故障排查

### 插件未加载

```bash
# 检查插件列表
cd /Users/robin/Work/hwork-bbs/discourse-2026.1.0-latest
bin/rails runner "puts Discourse.plugins.map(&:name)"
```

### 配置未生效

```bash
# 检查配置
bin/rails runner "puts SiteSetting.hwork_sso_enabled"
bin/rails runner "puts SiteSetting.hwork_api_url"
```

### 认证失败

查看日志：
```bash
tail -f log/development.log | grep "Hwork"
```

## 下一步

1. ✅ 插件已创建并可用
2. 测试所有功能
3. 根据需要调整配置
4. 考虑添加单元测试
5. 考虑发布到 GitHub

## 注意事项

- 插件默认启用，如需禁用可在管理后台关闭
- Token 缓存时长默认 5 分钟，可根据需要调整
- 确保 Hwork API 地址可访问
- 建议在生产环境使用 HTTPS

## 支持

如有问题，请查看：
- `plugins/discourse-hwork-sso/README.md`
- Discourse 日志文件
- 浏览器控制台
