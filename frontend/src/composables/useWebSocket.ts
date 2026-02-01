/**
 * WebSocket组合式API
 * 用于接收模拟分析的实时更新
 */

import { ref, onUnmounted } from 'vue';
import { useSimulationStore } from '@/stores/simulation';

type WebSocketMessageHandler = (data: any) => void;
type WebSocketCloseHandler = () => void;
type WebSocketErrorHandler = (error: Event) => void;

/**
 * 使用WebSocket
 */
export function useWebSocket() {
  const simulationStore = useSimulationStore();

  let ws: UniApp.SocketTask | null = null;
  let reconnectTimer: number | null = null;
  let reconnectAttempts = 0;
  const maxReconnectAttempts = 5;
  const reconnectDelay = 3000;

  const connected = ref(false);
  const connecting = ref(false);

  /**
   * 连接WebSocket
   */
  function connect(url?: string) {
    if (ws || connecting.value) {
      return;
    }

    connecting.value = true;

    // 构建WebSocket URL
    const apiBaseUrl = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000';
    const wsUrl = url || apiBaseUrl.replace('http://', 'ws://').replace('https://', 'wss://') + '/api/v1/ws';

    ws = uni.connectSocket({
      url: wsUrl,
    });

    ws.onOpen(() => {
      console.log('WebSocket connected');
      connected.value = true;
      connecting.value = false;
      reconnectAttempts = 0;
      simulationStore.setWsConnected(true);
    });

    ws.onMessage((event) => {
      try {
        const message = JSON.parse(event.data);
        handleMessage(message);
      } catch (error) {
        console.error('Failed to parse WebSocket message:', error);
      }
    });

    ws.onError((error) => {
      console.error('WebSocket error:', error);
      connected.value = false;
      connecting.value = false;
      simulationStore.setWsConnected(false);

      // 尝试重连
      attemptReconnect();
    });

    ws.onClose(() => {
      console.log('WebSocket closed');
      connected.value = false;
      connecting.value = false;
      ws = null;
      simulationStore.setWsConnected(false);

      // 尝试重连
      attemptReconnect();
    });
  }

  /**
   * 处理消息
   */
  function handleMessage(message: any) {
    const { type, data, timestamp } = message;

    switch (type) {
      case 'connected':
        console.log('WebSocket server confirmed connection');
        break;

      case 'simulation_progress':
        // 更新模拟进度
        if (data.analysisId === simulationStore.currentAnalysis.id) {
          console.log('Simulation progress:', data.progress);
        }
        break;

      case 'simulation_completed':
        // 模拟完成
        if (data.analysisId === simulationStore.currentAnalysis.id) {
          console.log('Simulation completed');
        }
        break;

      case 'simulation_failed':
        // 模拟失败
        if (data.analysisId === simulationStore.currentAnalysis.id) {
          simulationStore.setError('模拟分析失败');
        }
        break;

      case 'pong':
        // 心跳响应
        break;

      default:
        console.log('Unknown WebSocket message type:', type);
    }
  }

  /**
   * 发送消息
   */
  function send(type: string, data?: any) {
    if (!connected.value || !ws) {
      console.warn('WebSocket not connected');
      return;
    }

    const message = {
      type,
      data,
      timestamp: Date.now(),
    };

    ws.send({
      data: JSON.stringify(message),
    });
  }

  /**
   * 订阅分析进度
   */
  function subscribe(analysisId: string) {
    send('subscribe', { analysisId });
  }

  /**
   * 发送心跳
   */
  function ping() {
    send('ping');
  }

  /**
   * 尝试重连
   */
  function attemptReconnect() {
    if (reconnectAttempts >= maxReconnectAttempts) {
      console.error('Max reconnect attempts reached');
      return;
    }

    if (reconnectTimer) {
      return;
    }

    reconnectAttempts++;
    console.log(`Attempting to reconnect (${reconnectAttempts}/${maxReconnectAttempts})...`);

    reconnectTimer = setTimeout(() => {
      reconnectTimer = null;
      connect();
    }, reconnectDelay);
  }

  /**
   * 断开连接
   */
  function disconnect() {
    if (reconnectTimer) {
      clearTimeout(reconnectTimer);
      reconnectTimer = null;
    }

    if (ws) {
      ws.close();
      ws = null;
    }

    connected.value = false;
    connecting.value = false;
    simulationStore.setWsConnected(false);
  }

  // 组件卸载时断开连接
  onUnmounted(() => {
    disconnect();
  });

  return {
    connected: computed(() => connected.value),
    connecting: computed(() => connecting.value),
    connect,
    disconnect,
    send,
    subscribe,
    ping,
  };
}
