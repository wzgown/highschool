/**
 * 数据库连接管理
 */

import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import * as schema from './schema';
import { logger } from '@shared/utils';

/**
 * 数据库配置
 */
interface DatabaseConfig {
  host?: string;
  port?: number;
  database?: string;
  user?: string;
  password?: string;
  ssl?: boolean;
  max_connections?: number;
}

/**
 * 获取数据库配置
 */
function getDatabaseConfig(): DatabaseConfig {
  return {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432'),
    database: process.env.DB_NAME || 'highschool',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || '',
    ssl: process.env.DB_SSL === 'true',
    max_connections: parseInt(process.env.DB_MAX_CONNECTIONS || '10'),
  };
}

/**
 * 创建PostgreSQL连接
 */
function createConnection() {
  const config = getDatabaseConfig();

  const connectionString = `postgres://${config.user}:${config.password}@${config.host}:${config.port}/${config.database}${config.ssl ? '?sslmode=require' : ''}`;

  const client = postgres(connectionString, {
    max: config.max_connections,
    idle_timeout: 20,
    connect_timeout: 10,
  });

  return drizzle(client, { schema });
}

/**
 * 数据库连接实例
 */
let dbInstance: ReturnType<typeof drizzle> | null = null;

/**
 * 获取数据库连接
 */
export function getDb() {
  if (!dbInstance) {
    logger.info('Creating database connection');
    dbInstance = createConnection();
  }
  return dbInstance;
}

/**
 * 关闭数据库连接
 */
export async function closeDb() {
  if (dbInstance) {
    // @ts-ignore - postgres client has close method
    await dbInstance.$client.end();
    dbInstance = null;
    logger.info('Database connection closed');
  }
}

/**
 * 测试数据库连接
 */
export async function testConnection(): Promise<boolean> {
  try {
    const db = getDb();
    // @ts-ignore - drizzle has $client property
    await db.$client`SELECT 1`;
    logger.info('Database connection test successful');
    return true;
  } catch (error) {
    logger.error('Database connection test failed', error);
    return false;
  }
}

// 导出类型
export type Database = ReturnType<typeof getDb>;
export type Schema = typeof schema;
