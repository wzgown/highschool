package config

import (
	"github.com/spf13/viper"
)

// Config 应用配置
type Config struct {
	Server   ServerConfig   `mapstructure:"server"`
	Database DatabaseConfig `mapstructure:"database"`
	Redis    RedisConfig    `mapstructure:"redis"`
	Log      LogConfig      `mapstructure:"log"`
	Tracing  TracingConfig  `mapstructure:"tracing"`
}

// ServerConfig 服务器配置
type ServerConfig struct {
	Host string `mapstructure:"host"`
	Port int    `mapstructure:"port"`
	Mode string `mapstructure:"mode"`
}

// DatabaseConfig 数据库配置
type DatabaseConfig struct {
	Host      string `mapstructure:"host"`
	Port      int    `mapstructure:"port"`
	Name      string `mapstructure:"name"`
	User      string `mapstructure:"user"`
	Password  string `mapstructure:"password"`
	SSLMode   string `mapstructure:"ssl_mode"`
	MaxConns  int32  `mapstructure:"max_conns"`
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

	// 环境变量支持
	viper.AutomaticEnv()
	viper.SetEnvPrefix("HS")

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
