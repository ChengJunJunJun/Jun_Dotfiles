# =============================================================================
# 模块化 Zsh 配置 - 主入口文件
# =============================================================================

# 基于当前文件位置推导配置路径，避免硬编码仓库目录
ZSHRC_PATH="${${(%):-%N}:A}"
ZSH_BASE_DIR="${ZSHRC_PATH:h}"
DOTFILES_ROOT="${ZSH_BASE_DIR:h:h}"
ZSH_CONFIG_DIR="${ZSH_BASE_DIR}/config"
ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
ZSH_COMPDUMP="${ZSH_CACHE_DIR}/.zcompdump"

# 模块加载函数
load_config() {
    local config_file="$1"
    local config_path="${ZSH_CONFIG_DIR}/${config_file}"

    if [[ -f "$config_path" ]]; then
        source "$config_path"
    else
        echo "Config file not found: $config_path"
    fi
}

# 1. 性能监控和基础设置 (必须最先加载)
load_config "performance.zsh"

# 2. 环境变量和PATH配置
load_config "environment.zsh"

# 3. 插件管理 (依赖性能监控函数)
load_config "plugins.zsh"

# 4. 补全系统配置
load_config "completion.zsh"

# 5. 快捷键配置
load_config "keybindings.zsh"

# 6. 别名配置
load_config "aliases.zsh"

# 7. fzf 配置 一个快速、通用的命令行模糊搜索工具
load_config "fzf.zsh"

# 8. 延迟加载功能 (最后加载)
load_config "lazy-loading.zsh"

# 清理临时函数
unfunction load_config
unset ZSHRC_PATH ZSH_BASE_DIR
