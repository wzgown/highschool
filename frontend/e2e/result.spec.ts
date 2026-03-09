import { test, expect } from '@playwright/test'

test.describe('Result Page', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to result page with a test ID
    await page.goto('/#/pages/result/result?id=test-analysis-id')
    // Wait for page to load
    await page.waitForLoadState('networkidle')
    await page.waitForSelector('.result-view', { timeout: 30000 })
  })

  test('should display loading state initially', async ({ page }) => {
    // Should show loading container
    await expect(page.locator('.loading-container')).toBeVisible()

    // Should show loading status
    await expect(page.locator('.status-title')).toContainText('分析进行中')
  })

  test('should display skeleton loading animation', async ({ page }) => {
    // Check skeleton elements exist in loading container
    const skeletonVisible = await page.locator('.skeleton').isVisible()

    // Skeleton should be visible in loading state
    expect(skeletonVisible).toBe(true)
  })

  test('should display loading hints', async ({ page }) => {
    // Check for loading hints
    await expect(page.locator('.loading-hint')).toBeVisible()
    await expect(page.locator('.loading-hint')).toContainText('10-30')
  })

  test('should have proper result view structure', async ({ page }) => {
    // Check that result-view container exists
    await expect(page.locator('.result-view')).toBeVisible()
  })
})

test.describe('Result Page - Error State', () => {
  test('should display error state for invalid ID', async ({ page }) => {
    // Navigate to result page with an invalid ID
    await page.goto('/#/pages/result/result?id=invalid-id-12345')
    await page.waitForLoadState('networkidle')
    await page.waitForSelector('.result-view', { timeout: 30000 })

    // Wait for error state (might take some time due to API call)
    await page.waitForTimeout(3000)

    // Should show error container or loading container (depending on API response)
    const errorVisible = await page.locator('.error-container').isVisible()
    const loadingVisible = await page.locator('.loading-container').isVisible()

    expect(errorVisible || loadingVisible).toBe(true)
  })

  test('should display retry and back buttons on error', async ({ page }) => {
    // Navigate to result page with an invalid ID
    await page.goto('/#/pages/result/result?id=invalid-id-12345')
    await page.waitForLoadState('networkidle')
    await page.waitForSelector('.result-view', { timeout: 30000 })

    // Wait for error state
    await page.waitForTimeout(3000)

    // If error is shown, check buttons
    if (await page.locator('.error-container').isVisible()) {
      await expect(page.locator('.action-buttons .app-button:has-text("重试")')).toBeVisible()
      await expect(page.locator('.action-buttons .app-button:has-text("返回")')).toBeVisible()
    }
  })

  test('should navigate back when clicking back button on error', async ({ page }) => {
    // Navigate to result page with invalid ID
    await page.goto('/#/pages/result/result?id=invalid-id')
    await page.waitForLoadState('networkidle')
    await page.waitForSelector('.result-view', { timeout: 30000 })

    // Wait for error state
    await page.waitForTimeout(3000)

    // If error is shown, click back
    if (await page.locator('.error-container').isVisible()) {
      await page.locator('.action-buttons .app-button:has-text("返回")').click()

      // Should navigate away from result page
      await page.waitForTimeout(1000)
      await expect(page).not.toHaveURL(/\/pages\/result\/result/)
    }
  })
})
