// Package llm OpenAI 兼容 Chat Completions 客户端
// 实现 internal/service/agent 的 agent.LLMClient 接口，仅依赖标准库。
package llm

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"strings"
	"time"

	"highschool-backend/internal/service/agent"
	"highschool-backend/pkg/config"
)

const defaultTimeout = 60 * time.Second

// Client OpenAI 兼容 LLM 客户端，实现 agent.LLMClient
type Client struct {
	baseURL    string
	apiKey     string
	model      string
	maxTokens  int
	httpClient *http.Client
}

// 编译期接口断言
var _ agent.LLMClient = (*Client)(nil)

// NewClient 构造 LLM 客户端；BaseURL 与 Model 必填
func NewClient(cfg config.LLMConfig) (*Client, error) {
	baseURL := strings.TrimRight(strings.TrimSpace(cfg.BaseURL), "/")
	if baseURL == "" {
		return nil, errors.New("llm: base_url is required")
	}
	if strings.TrimSpace(cfg.Model) == "" {
		return nil, errors.New("llm: model is required")
	}
	timeout := time.Duration(cfg.TimeoutSeconds) * time.Second
	if timeout <= 0 {
		timeout = defaultTimeout
	}
	return &Client{
		baseURL:    baseURL,
		apiKey:     cfg.APIKey,
		model:      cfg.Model,
		maxTokens:  cfg.MaxTokens,
		httpClient: &http.Client{Timeout: timeout},
	}, nil
}

// ---------- 请求/响应结构（OpenAI Chat Completions） ----------

type chatMessage struct {
	Role       string         `json:"role"`
	Content    string         `json:"content"`
	ToolCalls  []chatToolCall `json:"tool_calls,omitempty"`
	ToolCallID string         `json:"tool_call_id,omitempty"`
	Name       string         `json:"name,omitempty"`
}

type chatToolCall struct {
	ID       string `json:"id"`
	Type     string `json:"type"`
	Function struct {
		Name      string `json:"name"`
		Arguments string `json:"arguments"` // JSON 字符串
	} `json:"function"`
}

type chatTool struct {
	Type     string `json:"type"` // 恒为 "function"
	Function struct {
		Name        string         `json:"name"`
		Description string         `json:"description"`
		Parameters  map[string]any `json:"parameters"`
	} `json:"function"`
}

type chatRequest struct {
	Model          string        `json:"model"`
	Messages       []chatMessage `json:"messages"`
	Tools          []chatTool    `json:"tools,omitempty"`
	MaxTokens      int           `json:"max_tokens,omitempty"`
	Temperature    *float64      `json:"temperature,omitempty"`
	ResponseFormat *struct {
		Type string `json:"type"`
	} `json:"response_format,omitempty"`
}

type chatResponse struct {
	Choices []struct {
		Message struct {
			Content   string         `json:"content"`
			ToolCalls []chatToolCall `json:"tool_calls,omitempty"`
		} `json:"message"`
	} `json:"choices"`
	Usage struct {
		PromptTokens     int `json:"prompt_tokens"`
		CompletionTokens int `json:"completion_tokens"`
	} `json:"usage"`
}

// APIError LLM 接口返回的非 200 错误
type APIError struct {
	StatusCode int
	Body       string
}

func (e *APIError) Error() string {
	return fmt.Sprintf("llm: API returned status %d: %s", e.StatusCode, e.Body)
}

// Chat 调用 Chat Completions API，429/5xx 重试 1 次
func (c *Client) Chat(ctx context.Context, params agent.ChatParams) (*agent.ChatResult, error) {
	reqBody, err := json.Marshal(c.buildRequest(params))
	if err != nil {
		return nil, fmt.Errorf("llm: marshal request: %w", err)
	}

	var lastErr error
	for attempt := 0; attempt < 2; attempt++ {
		if attempt > 0 {
			select {
			case <-ctx.Done():
				return nil, lastErr
			case <-time.After(1 * time.Second): // 指数退避基数 1s
			}
		}
		result, retryable, err := c.doChat(ctx, reqBody)
		if err == nil {
			return result, nil
		}
		lastErr = err
		if !retryable {
			return nil, err
		}
	}
	return nil, lastErr
}

func (c *Client) buildRequest(params agent.ChatParams) chatRequest {
	msgs := make([]chatMessage, len(params.Messages))
	for i, m := range params.Messages {
		msg := chatMessage{
			Role:       m.Role,
			Content:    m.Content,
			ToolCallID: m.ToolCallID,
			Name:       m.Name,
		}
		for _, tc := range m.ToolCalls {
			ctc := chatToolCall{ID: tc.ID, Type: "function"}
			ctc.Function.Name = tc.Name
			ctc.Function.Arguments = tc.ArgumentsJSON
			msg.ToolCalls = append(msg.ToolCalls, ctc)
		}
		msgs[i] = msg
	}

	var tools []chatTool
	for _, t := range params.Tools {
		var tool chatTool
		tool.Type = "function"
		tool.Function.Name = t.Name
		tool.Function.Description = t.Description
		tool.Function.Parameters = t.ParametersJSON
		tools = append(tools, tool)
	}

	maxTokens := params.MaxTokens
	if maxTokens <= 0 {
		maxTokens = c.maxTokens
	}

	req := chatRequest{
		Model:     c.model,
		Messages:  msgs,
		Tools:     tools,
		MaxTokens: maxTokens,
	}
	if params.Temperature > 0 {
		req.Temperature = &params.Temperature
	}
	if params.ResponseJSON {
		req.ResponseFormat = &struct {
			Type string `json:"type"`
		}{Type: "json_object"}
	}
	return req
}

// doChat 执行一次 HTTP 调用；retryable 表示是否值得重试（429/5xx 或网络层错误）
func (c *Client) doChat(ctx context.Context, body []byte) (*agent.ChatResult, bool, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, c.baseURL+"/chat/completions", bytes.NewReader(body))
	if err != nil {
		return nil, false, fmt.Errorf("llm: build request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	if c.apiKey != "" {
		req.Header.Set("Authorization", "Bearer "+c.apiKey)
	}

	resp, err := c.httpClient.Do(req)
	if err != nil {
		// 上下文取消/超时不重试
		if ctx.Err() != nil || errors.Is(err, context.DeadlineExceeded) || errors.Is(err, context.Canceled) {
			return nil, false, fmt.Errorf("llm: request: %w", err)
		}
		var netErr net.Error
		retryable := errors.As(err, &netErr)
		return nil, retryable, fmt.Errorf("llm: request: %w", err)
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(io.LimitReader(resp.Body, 1<<20))
	if err != nil {
		return nil, false, fmt.Errorf("llm: read response: %w", err)
	}

	if resp.StatusCode != http.StatusOK {
		apiErr := &APIError{StatusCode: resp.StatusCode, Body: summarizeBody(respBody)}
		retryable := resp.StatusCode == http.StatusTooManyRequests || resp.StatusCode >= 500
		return nil, retryable, apiErr
	}

	var cr chatResponse
	if err := json.Unmarshal(respBody, &cr); err != nil {
		return nil, false, fmt.Errorf("llm: decode response: %w", err)
	}
	if len(cr.Choices) == 0 {
		return nil, false, errors.New("llm: response has no choices")
	}

	msg := cr.Choices[0].Message
	result := &agent.ChatResult{
		Content:          msg.Content,
		PromptTokens:     cr.Usage.PromptTokens,
		CompletionTokens: cr.Usage.CompletionTokens,
	}
	for _, tc := range msg.ToolCalls {
		result.ToolCalls = append(result.ToolCalls, agent.LLMToolCall{
			ID:            tc.ID,
			Name:          tc.Function.Name,
			ArgumentsJSON: tc.Function.Arguments,
		})
	}
	return result, false, nil
}

// summarizeBody 截断错误响应体用于错误信息
func summarizeBody(body []byte) string {
	const maxLen = 512
	s := strings.TrimSpace(string(body))
	if len(s) > maxLen {
		s = s[:maxLen] + "..."
	}
	return s
}
