package config

import (
	"strings"

	"github.com/spf13/viper"
)

// Config 应用配置
type Config struct {
	Server   ServerConfig   `mapstructure:"server"`
	Database DatabaseConfig `mapstructure:"database"`
	Redis    RedisConfig    `mapstructure:"redis"`
	Log      LogConfig      `mapstructure:"log"`
	Tracing  TracingConfig  `mapstructure:"tracing"`
	Tip      TipConfig      `mapstructure:"tip"`
	LLM      LLMConfig      `mapstructure:"llm"`
	Agent    AgentConfig    `mapstructure:"agent"`
	WeChat   WeChatConfig   `mapstructure:"wechat"`
	Feature  FeatureConfig  `mapstructure:"feature"`
}

// LLMConfig LLM（OpenAI 兼容）配置
type LLMConfig struct {
	Provider       string `mapstructure:"provider"`
	BaseURL        string `mapstructure:"base_url"`
	APIKey         string `mapstructure:"api_key"`
	Model          string `mapstructure:"model"`
	MaxTokens      int    `mapstructure:"max_tokens"`
	TimeoutSeconds int    `mapstructure:"timeout_seconds"`
}

// AgentConfig AI 顾问 Agent 模式配置
type AgentConfig struct {
	MaxReplan            int  `mapstructure:"max_replan"`
	StepBudget           int  `mapstructure:"step_budget"`
	SessionTTLHours      int  `mapstructure:"session_ttl_hours"`
	DailyQuota           int  `mapstructure:"daily_quota"`
	MaxContextMessages   int  `mapstructure:"max_context_messages"`
	MaxLLMConcurrency    int  `mapstructure:"max_llm_concurrency"`
	ReflectionLLMEnabled bool `mapstructure:"reflection_llm_enabled"`
}

// WeChatConfig 微信小程序配置（内容安全 msgSecCheck）
type WeChatConfig struct {
	AppID  string `mapstructure:"appid"`
	Secret string `mapstructure:"secret"` // 仅经环境变量 HS_WECHAT_SECRET 注入
}

// FeatureConfig 功能开关（审核期隐藏 AI 顾问等，远程可控）
type FeatureConfig struct {
	AgentEnabled   bool     `mapstructure:"agent_enabled"`  // AI 顾问总开关
	ReviewVersions []string `mapstructure:"review_versions"` // 审核中的小程序版本：这些版本强制关闭
}

// TipConfig 打赏码配置
type TipConfig struct {
	Enabled        bool     `mapstructure:"enabled"`
	QrURL          string   `mapstructure:"qr_url"`
	ReviewVersions []string `mapstructure:"review_versions"`
}

// ServerConfig 服务器配置
type ServerConfig struct {
	Host string `mapstructure:"host"`
	Port int    `mapstructure:"port"`
	Mode string `mapstructure:"mode"`
}

// DatabaseConfig 数据库配置
type DatabaseConfig struct {
	Host     string `mapstructure:"host"`
	Port     int    `mapstructure:"port"`
	Name     string `mapstructure:"name"`
	User     string `mapstructure:"user"`
	Password string `mapstructure:"password"`
	SSLMode  string `mapstructure:"ssl_mode"`
	MaxConns int32  `mapstructure:"max_conns"`
}

// RedisConfig Redis配置
type RedisConfig struct {
	Host     string `mapstructure:"host"`
	Port     int    `mapstructure:"port"`
	Password string `mapstructure:"password"`
	DB       int    `mapstructure:"db"`
}

// LogConfig 日志配置
type LogConfig struct {
	Level  string `mapstructure:"level"`
	Format string `mapstructure:"format"`
}

// TracingConfig 分布式追踪配置
type TracingConfig struct {
	Enabled      bool    `mapstructure:"enabled"`
	ServiceName  string  `mapstructure:"service_name"`
	OTLPEndpoint string  `mapstructure:"otlp_endpoint"`
	SampleRate   float64 `mapstructure:"sample_rate"`
}

// Load 加载配置
func Load() (*Config, error) {
	viper.SetConfigName("config")
	viper.SetConfigType("yaml")
	viper.AddConfigPath(".")
	viper.AddConfigPath("./config")
	viper.AddConfigPath("/etc/highschool/")

	// 默认值
	viper.SetDefault("server.host", "0.0.0.0")
	viper.SetDefault("server.port", 3000)
	viper.SetDefault("server.mode", "development")
	viper.SetDefault("database.host", "localhost")
	viper.SetDefault("database.port", 5432)
	viper.SetDefault("database.name", "highschool")
	viper.SetDefault("database.user", "highschool")
	viper.SetDefault("database.ssl_mode", "disable")
	viper.SetDefault("database.max_conns", 10)
	viper.SetDefault("redis.host", "localhost")
	viper.SetDefault("redis.port", 6379)
	viper.SetDefault("redis.db", 0)
	viper.SetDefault("log.level", "info")
	viper.SetDefault("log.format", "json")
	viper.SetDefault("tracing.enabled", false)
	viper.SetDefault("tracing.service_name", "highschool-backend")
	viper.SetDefault("tracing.otlp_endpoint", "localhost:4317")
	viper.SetDefault("tracing.sample_rate", 1.0)
	viper.SetDefault("tip.enabled", true)
	viper.SetDefault("tip.qr_url", "")
	viper.SetDefault("tip.review_versions", []string{})
	viper.SetDefault("llm.provider", "deepseek")
	viper.SetDefault("llm.base_url", "https://api.deepseek.com")
	viper.SetDefault("llm.model", "deepseek-chat")
	viper.SetDefault("llm.max_tokens", 800)
	viper.SetDefault("llm.timeout_seconds", 60)
	viper.SetDefault("agent.max_replan", 2)
	viper.SetDefault("agent.step_budget", 12)
	viper.SetDefault("agent.session_ttl_hours", 72)
	viper.SetDefault("agent.daily_quota", 50)
	viper.SetDefault("agent.max_context_messages", 20)
	viper.SetDefault("agent.max_llm_concurrency", 10)
	viper.SetDefault("agent.reflection_llm_enabled", false)
	viper.SetDefault("wechat.appid", "")
	viper.SetDefault("feature.agent_enabled", true)

	// 环境变量支持 - 使用 EnvKeyReplacer 将 database.host 映射到 HS_DATABASE_HOST
	viper.SetEnvPrefix("HS")
	viper.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))
	viper.AutomaticEnv()

	if err := viper.ReadInConfig(); err != nil {
		if _, ok := err.(viper.ConfigFileNotFoundError); !ok {
			return nil, err
		}
	}

	var cfg Config
	if err := viper.Unmarshal(&cfg); err != nil {
		return nil, err
	}

	return &cfg, nil
}
