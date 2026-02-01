/**
 * 随机数生成工具
 */

/**
 * 生成指定范围内的随机整数（包含边界）
 */
export function randomInt(min: number, max: number): number {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

/**
 * 生成正态分布随机数（Box-Muller变换）
 */
export function randomNormal(mean: number, stdDev: number): number {
  let u = 0;
  let v = 0;

  while (u === 0) {
    u = Math.random(); // Converting [0,1) to (0,1)
  }
  while (v === 0) {
    v = Math.random();
  }

  const z = Math.sqrt(-2.0 * Math.log(u)) * Math.cos(2.0 * Math.PI * v);

  return z * stdDev + mean;
}

/**
 * 生成指定范围内的正态分布随机数（截断）
 */
export function randomNormalBounded(mean: number, stdDev: number, min: number, max: number): number {
  let value = randomNormal(mean, stdDev);
  return Math.max(min, Math.min(max, value));
}

/**
 * 从数组中随机选择一个元素
 */
export function randomChoice<T>(array: T[]): T {
  return array[Math.floor(Math.random() * array.length)];
}

/**
 * 从数组中随机选择n个不重复的元素
 */
export function randomSample<T>(array: T[], n: number): T[] {
  const shuffled = [...array].sort(() => Math.random() - 0.5);
  return shuffled.slice(0, Math.min(n, array.length));
}

/**
 * 生成带权重的随机选择
 */
export function weightedRandomChoice<T>(items: Array<{ item: T; weight: number }>): T {
  const totalWeight = items.reduce((sum, { weight }) => sum + weight, 0);
  let random = Math.random() * totalWeight;

  for (const { item, weight } of items) {
    random -= weight;
    if (random <= 0) {
      return item;
    }
  }

  return items[0].item;
}

/**
 * 洗牌算法（Fisher-Yates）
 */
export function shuffle<T>(array: T[]): T[] {
  const result = [...array];
  for (let i = result.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [result[i], result[j]] = [result[j], result[i]];
  }
  return result;
}

/**
 * 生成泊松分布随机数
 */
export function randomPoisson(lambda: number): number {
  const L = Math.exp(-lambda);
  let k = 0;
  let p = 1;

  do {
    k++;
    p *= Math.random();
  } while (p > L);

  return k - 1;
}
