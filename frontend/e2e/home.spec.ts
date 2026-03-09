import { test, expect } from '@playwright/test'

test.describe('Homepage', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/')
    // Wait for the page to be fully loaded (uni-app has initial loading state)
    await page.waitForLoadState('networkidle')
    // Wait for the home view to be visible
    await page.waitForSelector('.home-view', { timeout: 30000 })
  })

  test('should load homepage successfully', async ({ page }) => {
    // Check page title
    await expect(page.locator('.title-text')).toContainText('上海中考招生模拟系统')

    // Check hero section exists
    await expect(page.locator('.hero-section')).toBeVisible()

    // Check hero subtitle
    await expect(page.locator('.hero-subtitle')).toContainText('历年录取数据')
  })

  test('should display three main action buttons', async ({ page }) => {
    // Check main action buttons exist
    const buttons = page.locator('.hero-actions .app-button')
    await expect(buttons).toHaveCount(3)

    // Check button texts
    await expect(buttons.nth(0)).toContainText('智能志愿推荐')
    await expect(buttons.nth(1)).toContainText('志愿模拟分析')
    await expect(buttons.nth(2)).toContainText('历史记录')
  })

  test('should display feature cards section', async ({ page }) => {
    // Check section title
    await expect(page.locator('.section-title').first()).toContainText('核心功能')

    // Check feature cards exist
    const featureCards = page.locator('.feature-card')
    await expect(featureCards).toHaveCount(4)

    // Check first card (highlighted) contains correct content
    await expect(featureCards.first()).toContainText('智能志愿推荐')
  })

  test('should display batch information section', async ({ page }) => {
    // Check batch section
    const batchSection = page.locator('.batch-section')
    await expect(batchSection).toBeVisible()

    // Check batch cards
    const batchCards = page.locator('.batch-list .app-card')
    await expect(batchCards).toHaveCount(3)

    // Check batch names
    await expect(page.locator('.batch-header-text').first()).toContainText('名额分配到区')
  })

  test('should display disclaimer section', async ({ page }) => {
    // Check notice section
    await expect(page.locator('.notice-section')).toBeVisible()
    await expect(page.locator('.notice-title')).toContainText('免责声明')
    await expect(page.locator('.notice-content')).toContainText('仅供参考')
  })

  test('should navigate to form page when clicking analysis button', async ({ page }) => {
    // Click the analysis button
    await page.locator('.hero-actions .app-button').nth(1).click()

    // Wait for navigation
    await page.waitForURL(/\/pages\/form\/form/, { timeout: 10000 })

    // Should navigate to form page
    await expect(page).toHaveURL(/\/pages\/form\/form/)
  })

  test('should navigate to history page when clicking history button', async ({ page }) => {
    // Click the history button
    await page.locator('.hero-actions .app-button').nth(2).click()

    // Wait for navigation
    await page.waitForURL(/\/pages\/history\/history/, { timeout: 10000 })

    // Should navigate to history page
    await expect(page).toHaveURL(/\/pages\/history\/history/)
  })

  test('should navigate to recommendation page when clicking recommendation button', async ({ page }) => {
    // Click the recommendation button (highlighted feature card)
    await page.locator('.feature-card--highlight').click()

    // Wait for navigation
    await page.waitForURL(/\/pages\/recommendation\/recommendation/, { timeout: 10000 })

    // Should navigate to recommendation page
    await expect(page).toHaveURL(/\/pages\/recommendation\/recommendation/)
  })
})
