import { test, expect } from '@playwright/test'

test.describe('History Page', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/#/pages/history/history')
    // Wait for page to load
    await page.waitForLoadState('networkidle')
    await page.waitForSelector('.page-container', { timeout: 30000 })
  })

  test('should display page header', async ({ page }) => {
    // Check page title
    await expect(page.locator('.page-title')).toContainText('历史记录')

    // Check page description
    await expect(page.locator('.page-desc')).toContainText('志愿分析记录')
  })

  test('should display either loading, empty state or history list', async ({ page }) => {
    // Wait a bit for content to load
    await page.waitForTimeout(1000)

    // One of these states should be visible
    const loadingVisible = await page.locator('.loading-container').isVisible()
    const emptyVisible = await page.locator('.empty-container').isVisible()
    const listVisible = await page.locator('.history-list').isVisible()

    expect(loadingVisible || emptyVisible || listVisible).toBe(true)
  })

  test('should display empty state with start button when no history', async ({ page }) => {
    // Wait for content to load
    await page.waitForTimeout(1000)

    // Check if empty state is visible
    const emptyVisible = await page.locator('.empty-container').isVisible()

    if (emptyVisible) {
      // Check empty icon exists
      await expect(page.locator('.empty-container uni-icons')).toBeVisible()

      // Check empty text
      await expect(page.locator('.empty-text')).toContainText('暂无历史记录')

      // Check start button
      await expect(page.locator('.empty-container .app-button:has-text("开始新的分析")')).toBeVisible()
    }
  })

  test('should navigate to form when clicking start button in empty state', async ({ page }) => {
    // Wait for content to load
    await page.waitForTimeout(1000)

    // Check if empty state is visible
    const emptyVisible = await page.locator('.empty-container').isVisible()

    if (emptyVisible) {
      // Click start button
      await page.locator('.empty-container .app-button:has-text("开始新的分析")').click()

      // Should navigate to form page
      await page.waitForURL(/\/pages\/form\/form/, { timeout: 10000 })
      await expect(page).toHaveURL(/\/pages\/form\/form/)
    }
  })

  test('should display page container structure', async ({ page }) => {
    // Check page container structure
    await expect(page.locator('.page-header')).toBeVisible()
    await expect(page.locator('.page-title')).toBeVisible()
  })
})

test.describe('History Page - With Data', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/#/pages/history/history')
    await page.waitForLoadState('networkidle')
    await page.waitForSelector('.page-container', { timeout: 30000 })
  })

  test('should display action bar when history list is visible', async ({ page }) => {
    // Wait for content to load
    await page.waitForTimeout(1500)

    // Check if history list is visible (has data)
    const listVisible = await page.locator('.history-list').isVisible()

    if (listVisible) {
      // Check action bar
      await expect(page.locator('.action-bar')).toBeVisible()

      // Check total info
      await expect(page.locator('.total-text')).toContainText('记录')

      // Check clear button
      await expect(page.locator('.clear-btn')).toBeVisible()
    }
  })

  test('should display history cards with correct structure', async ({ page }) => {
    // Wait for content to load
    await page.waitForTimeout(1500)

    // Check if history list is visible
    const listVisible = await page.locator('.history-list').isVisible()

    if (listVisible) {
      // Check history cards
      const historyCards = page.locator('.history-card')
      const count = await historyCards.count()
      expect(count).toBeGreaterThan(0)

      // Check first card structure
      const firstCard = historyCards.first()
      await expect(firstCard.locator('.history-item')).toBeVisible()
      await expect(firstCard.locator('.history-time')).toBeVisible()
    }
  })

  test('should display action buttons on history cards', async ({ page }) => {
    // Wait for content to load
    await page.waitForTimeout(1500)

    // Check if history list is visible
    const listVisible = await page.locator('.history-list').isVisible()

    if (listVisible) {
      // Check action buttons on first card
      const firstCard = page.locator('.history-card').first()
      await expect(firstCard.locator('.action-btn.view:has-text("查看详情")')).toBeVisible()
      await expect(firstCard.locator('.action-btn.delete:has-text("删除")')).toBeVisible()
    }
  })

  test('should display load more or no more indicator', async ({ page }) => {
    // Wait for content to load
    await page.waitForTimeout(1500)

    // Check if history list is visible
    const listVisible = await page.locator('.history-list').isVisible()

    if (listVisible) {
      // Check if load more button exists
      const loadMoreVisible = await page.locator('.load-more').isVisible()
      const noMoreVisible = await page.locator('.no-more').isVisible()

      // One of these should be visible when there are items
      const historyCount = await page.locator('.history-card').count()
      if (historyCount > 0) {
        expect(loadMoreVisible || noMoreVisible).toBe(true)
      }
    }
  })
})

test.describe('History Page - Delete Actions', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/#/pages/history/history')
    await page.waitForLoadState('networkidle')
    await page.waitForSelector('.page-container', { timeout: 30000 })
  })

  test('should have delete button on history cards', async ({ page }) => {
    // Wait for content to load
    await page.waitForTimeout(1500)

    // Check if history list is visible
    const listVisible = await page.locator('.history-list').isVisible()

    if (listVisible) {
      // Check delete button exists on first card
      const deleteBtn = page.locator('.history-card').first().locator('.action-btn.delete')
      await expect(deleteBtn).toBeVisible()
      await expect(deleteBtn).toContainText('删除')
    }
  })

  test('should have clear all button when history exists', async ({ page }) => {
    // Wait for content to load
    await page.waitForTimeout(1500)

    // Check if history list is visible
    const listVisible = await page.locator('.history-list').isVisible()

    if (listVisible) {
      // Check clear all button
      const clearBtn = page.locator('.clear-btn')
      await expect(clearBtn).toBeVisible()
      await expect(clearBtn.locator('.clear-text')).toContainText('清空全部')
    }
  })
})
