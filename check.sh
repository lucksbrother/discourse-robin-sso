#!/bin/bash

# Hwork SSO 插件检查脚本

echo "🔍 检查 Hwork SSO 插件..."
echo ""

PLUGIN_DIR="/Users/robin/Work/hwork-bbs/discourse_docker-main/image/base/discourse-2026.1.0-latest/plugins/discourse-hwork-sso"

# 检查插件目录
if [ -d "$PLUGIN_DIR" ]; then
    echo "✅ 插件目录存在"
else
    echo "❌ 插件目录不存在"
    exit 1
fi

# 检查必需文件
echo ""
echo "📁 检查必需文件..."

files=(
    "plugin.rb"
    "lib/hwork_token_current_user_provider.rb"
    "app/controllers/hwork_sso_controller.rb"
    "assets/javascripts/discourse/initializers/hwork-sso.js"
    "config/settings.yml"
    "config/locales/server.en.yml"
    "config/locales/server.zh_CN.yml"
)

for file in "${files[@]}"; do
    if [ -f "$PLUGIN_DIR/$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file"
    fi
done

# 检查文档
echo ""
echo "📖 检查文档..."

docs=(
    "README.md"
    "QUICKSTART.md"
    "MIGRATION.md"
    "SUMMARY.md"
    "INSTALL.md"
)

for doc in "${docs[@]}"; do
    if [ -f "$PLUGIN_DIR/$doc" ]; then
        echo "  ✅ $doc"
    else
        echo "  ❌ $doc"
    fi
done

# 统计
echo ""
echo "📊 统计信息..."
echo "  总文件数: $(find "$PLUGIN_DIR" -type f | wc -l | tr -d ' ')"
echo "  Ruby 文件: $(find "$PLUGIN_DIR" -name "*.rb" | wc -l | tr -d ' ')"
echo "  JS 文件: $(find "$PLUGIN_DIR" -name "*.js" | wc -l | tr -d ' ')"
echo "  配置文件: $(find "$PLUGIN_DIR" -name "*.yml" | wc -l | tr -d ' ')"
echo "  文档文件: $(find "$PLUGIN_DIR" -name "*.md" | wc -l | tr -d ' ')"

echo ""
echo "✅ 插件检查完成！"
echo ""
echo "🚀 快速开始:"
echo "  1. cd /Users/robin/Work/hwork-bbs/discourse-2026.1.0-latest"
echo "  2. bin/rails server"
echo "  3. 访问: http://localhost:3000/plugins/discourse-hwork-sso/test.html"
echo ""
echo "📚 查看文档:"
echo "  cat $PLUGIN_DIR/QUICKSTART.md"
