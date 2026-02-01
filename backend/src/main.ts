/**
 * 后端服务入口文件
 */

import { startServer } from './app';
import { closeDb } from './infrastructure/database';
import { logger } from '@shared/utils';

/**
 * 主函数
 */
async function main() {
  let app;

  try {
    app = await startServer();

    // 优雅关闭
    const shutdown = async (signal: string) => {
      logger.info(`Received ${signal}, shutting down gracefully...`);

      try {
        if (app) {
          await app.close();
        }
        await closeDb();
        logger.info('Server shut down successfully');
        process.exit(0);
      } catch (error) {
        logger.error('Error during shutdown', error);
        process.exit(1);
      }
    };

    process.on('SIGTERM', () => shutdown('SIGTERM'));
    process.on('SIGINT', () => shutdown('SIGINT'));

  } catch (error) {
    logger.error('Failed to start server', error);
    process.exit(1);
  }
}

// 启动服务
main();
