package llm

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"sync/atomic"
	"testing"

	"highschool-backend/internal/service/agent"
	"highschool-backend/pkg/config"
)

// capturedRequest 记录服务端收到的请求体
type capturedRequest struct {
	Model          string   `json:"model"`
	MaxTokens      int      `json:"max_tokens"`
	Temperature    *float64 `json:"temperature"`
	ResponseFormat *struct {
		Type string `json:"type"`
	} `json:"response_format"`
	Messages []struct {
		Role    string `json:"role"`
		Content string `json:"content"`
	} `json:"messages"`
	Tools []struct {
		Type     string `json:"type"`
		Function struct {
			Name        string         `json:"name"`
			Description string         `json:"description"`
			Parameters  map[string]any `json:"parameters"`
		} `json:"function"`
	} `json:"tools"`
}

func newTestClient(t *testing.T, baseURL string) *Client {
	t.Helper()
	c, err := NewClient(config.LLMConfig{
		BaseURL:        baseURL,
		APIKey:         "test-key",
		Model:          "deepseek-chat",
		MaxTokens:      800,
		TimeoutSeconds: 5,
	})
	if err != nil {
		t.Fatalf("NewClient: %v", err)
	}
	return c
}

func TestChat_PlainContent(t *testing.T) {
	var captured capturedRequest
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/chat/completions" {
			t.Errorf("unexpected path: %s", r.URL.Path)
		}
		if got := r.Header.Get("Authorization"); got != "Bearer test-key" {
			t.Errorf("unexpected auth header: %q", got)
		}
		if err := json.NewDecoder(r.Body).Decode(&captured); err != nil {
			t.Errorf("decode request: %v", err)
		}
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{
			"choices": [{"message": {"role": "assistant", "content": "你好，我是 AI 顾问"}}],
			"usage": {"prompt_tokens": 12, "completion_tokens": 8}
		}`))
	}))
	defer srv.Close()

	c := newTestClient(t, srv.URL)
	result, err := c.Chat(context.Background(), agent.ChatParams{
		Messages: []agent.Message{
			{Role: agent.RoleSystem, Content: "你是顾问"},
			{Role: agent.RoleUser, Content: "你好"},
		},
		MaxTokens:   100,
		Temperature: 0.7,
	})
	if err != nil {
		t.Fatalf("Chat: %v", err)
	}
	if result.Content != "你好，我是 AI 顾问" {
		t.Errorf("content = %q", result.Content)
	}
	if len(result.ToolCalls) != 0 {
		t.Errorf("unexpected tool calls: %+v", result.ToolCalls)
	}
	if result.PromptTokens != 12 || result.CompletionTokens != 8 {
		t.Errorf("usage = %d/%d", result.PromptTokens, result.CompletionTokens)
	}
	if captured.Model != "deepseek-chat" || captured.MaxTokens != 100 {
		t.Errorf("request model/max_tokens = %s/%d", captured.Model, captured.MaxTokens)
	}
	if captured.Temperature == nil || *captured.Temperature != 0.7 {
		t.Errorf("temperature not propagated: %v", captured.Temperature)
	}
	if len(captured.Messages) != 2 || captured.Messages[0].Role != "system" {
		t.Errorf("messages = %+v", captured.Messages)
	}
	if len(captured.Tools) != 0 {
		t.Errorf("tools should be omitted, got %+v", captured.Tools)
	}
	if captured.ResponseFormat != nil {
		t.Errorf("response_format should be omitted")
	}
}

func TestChat_ToolCallsAndJSONMode(t *testing.T) {
	var captured capturedRequest
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_ = json.NewDecoder(r.Body).Decode(&captured)
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{
			"choices": [{"message": {
				"role": "assistant",
				"content": "",
				"tool_calls": [{
					"id": "call_abc123",
					"type": "function",
					"function": {"name": "query_score_lines", "arguments": "{\"school_name\":\"福州一中\"}"}
				}]
			}}],
			"usage": {"prompt_tokens": 30, "completion_tokens": 15}
		}`))
	}))
	defer srv.Close()

	c := newTestClient(t, srv.URL)
	result, err := c.Chat(context.Background(), agent.ChatParams{
		Messages: []agent.Message{
			{Role: agent.RoleUser, Content: "查福州一中分数线"},
		},
		Tools: []agent.ToolSpec{
			{
				Name:        "query_score_lines",
				Description: "查询学校分数线",
				ParametersJSON: map[string]any{
					"type": "object",
					"properties": map[string]any{
						"school_name": map[string]any{"type": "string"},
					},
				},
			},
		},
		ResponseJSON: true,
	})
	if err != nil {
		t.Fatalf("Chat: %v", err)
	}
	if len(result.ToolCalls) != 1 {
		t.Fatalf("tool calls = %+v", result.ToolCalls)
	}
	tc := result.ToolCalls[0]
	if tc.ID != "call_abc123" || tc.Name != "query_score_lines" {
		t.Errorf("tool call = %+v", tc)
	}
	var args map[string]any
	if err := json.Unmarshal([]byte(tc.ArgumentsJSON), &args); err != nil {
		t.Fatalf("arguments is not valid JSON: %v", err)
	}
	if args["school_name"] != "福州一中" {
		t.Errorf("arguments = %v", args)
	}
	if result.PromptTokens != 30 || result.CompletionTokens != 15 {
		t.Errorf("usage = %d/%d", result.PromptTokens, result.CompletionTokens)
	}

	// 请求侧校验：tools 与 response_format
	if len(captured.Tools) != 1 || captured.Tools[0].Type != "function" {
		t.Fatalf("tools = %+v", captured.Tools)
	}
	if captured.Tools[0].Function.Name != "query_score_lines" {
		t.Errorf("tool name = %q", captured.Tools[0].Function.Name)
	}
	if captured.Tools[0].Function.Parameters["type"] != "object" {
		t.Errorf("tool parameters = %+v", captured.Tools[0].Function.Parameters)
	}
	if captured.ResponseFormat == nil || captured.ResponseFormat.Type != "json_object" {
		t.Errorf("response_format = %+v", captured.ResponseFormat)
	}
}

func TestChat_Non200Error(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusBadRequest)
		_, _ = w.Write([]byte(`{"error":{"message":"invalid model"}}`))
	}))
	defer srv.Close()

	c := newTestClient(t, srv.URL)
	_, err := c.Chat(context.Background(), agent.ChatParams{
		Messages: []agent.Message{{Role: agent.RoleUser, Content: "hi"}},
	})
	if err == nil {
		t.Fatal("expected error, got nil")
	}
	var apiErr *APIError
	if !errors.As(err, &apiErr) {
		t.Fatalf("expected APIError, got %T: %v", err, err)
	}
	if apiErr.StatusCode != http.StatusBadRequest {
		t.Errorf("status = %d", apiErr.StatusCode)
	}
	if apiErr.Body == "" {
		t.Error("expected body summary in error")
	}
}

func TestChat_RetryOn5xx(t *testing.T) {
	var calls int32
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		n := atomic.AddInt32(&calls, 1)
		if n == 1 {
			w.WriteHeader(http.StatusInternalServerError)
			_, _ = w.Write([]byte(`{"error":{"message":"overloaded"}}`))
			return
		}
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{
			"choices": [{"message": {"role": "assistant", "content": "重试成功"}}],
			"usage": {"prompt_tokens": 1, "completion_tokens": 1}
		}`))
	}))
	defer srv.Close()

	c := newTestClient(t, srv.URL)
	result, err := c.Chat(context.Background(), agent.ChatParams{
		Messages: []agent.Message{{Role: agent.RoleUser, Content: "hi"}},
	})
	if err != nil {
		t.Fatalf("Chat: %v", err)
	}
	if result.Content != "重试成功" {
		t.Errorf("content = %q", result.Content)
	}
	if got := atomic.LoadInt32(&calls); got != 2 {
		t.Errorf("expected 2 calls (1 retry), got %d", got)
	}
}

func TestChat_RetryOn429(t *testing.T) {
	var calls int32
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		atomic.AddInt32(&calls, 1)
		w.WriteHeader(http.StatusTooManyRequests)
		_, _ = w.Write([]byte(`{"error":{"message":"rate limited"}}`))
	}))
	defer srv.Close()

	c := newTestClient(t, srv.URL)
	_, err := c.Chat(context.Background(), agent.ChatParams{
		Messages: []agent.Message{{Role: agent.RoleUser, Content: "hi"}},
	})
	if err == nil {
		t.Fatal("expected error after retry exhausted")
	}
	if got := atomic.LoadInt32(&calls); got != 2 {
		t.Errorf("expected 2 calls (1 retry), got %d", got)
	}
}

func TestChat_NoRetryOn400(t *testing.T) {
	var calls int32
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		atomic.AddInt32(&calls, 1)
		w.WriteHeader(http.StatusBadRequest)
		_, _ = w.Write([]byte(`{}`))
	}))
	defer srv.Close()

	c := newTestClient(t, srv.URL)
	_, err := c.Chat(context.Background(), agent.ChatParams{
		Messages: []agent.Message{{Role: agent.RoleUser, Content: "hi"}},
	})
	if err == nil {
		t.Fatal("expected error")
	}
	if got := atomic.LoadInt32(&calls); got != 1 {
		t.Errorf("400 should not be retried, got %d calls", got)
	}
}

func TestNewClient_Validation(t *testing.T) {
	if _, err := NewClient(config.LLMConfig{}); err == nil {
		t.Error("expected error for empty base_url")
	}
	if _, err := NewClient(config.LLMConfig{BaseURL: "http://x"}); err == nil {
		t.Error("expected error for empty model")
	}
}
