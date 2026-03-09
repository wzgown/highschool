import { test, expect } from '@playwright/test'

test.describe('Volunteer Form', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/#/pages/form/form')
    // Wait for the page to be fully loaded
    await page.waitForLoadState('networkidle')
    // Wait for the form container to be visible
    await page.waitForSelector('.page-container', { timeout: 30000 })
  })

  test('should display three-step wizard', async ({ page }) => {
    // Wait for steps to be visible
    await page.waitForSelector('.steps', { timeout: 10000 })

    // Check step names
    const stepNames = page.locator('.step-name')
    await expect(stepNames).toHaveCount(3)
    await expect(stepNames.nth(0)).toContainText('基本信息')
    await expect(stepNames.nth(1)).toContainText('成绩信息')
    await expect(stepNames.nth(2)).toContainText('志愿填报')
  })

  test('should start at step 1 with disabled next button', async ({ page }) => {
    // Wait for steps to be visible
    await page.waitForSelector('.steps', { timeout: 10000 })

    // Check first step is active
    await expect(page.locator('.step-item').nth(0)).toHaveClass(/active/)

    // Next button should be disabled initially
    const nextButton = page.locator('.form-actions .app-button:has-text("下一步")')
    await expect(nextButton).toBeDisabled()
  })

  test('should display basic info form fields in step 1', async ({ page }) => {
    // Wait for form to be ready
    await page.waitForSelector('.form-card', { timeout: 10000 })

    // Check card title
    await expect(page.locator('.card-title')).toContainText('考生基本信息')

    // Check form labels exist
    await expect(page.locator('.form-label:has-text("所属区县")')).toBeVisible()
    await expect(page.locator('.form-label:has-text("初中学校")')).toBeVisible()
  })

  test('should display quota eligibility checkbox', async ({ page }) => {
    // Wait for form to be ready
    await page.waitForSelector('.form-body', { timeout: 10000 })

    // Check quota eligibility checkbox exists
    await expect(page.locator('.checkbox-label:has-text("具备名额分配到校填报资格")')).toBeVisible()
  })

  test('should have correct step indicator states', async ({ page }) => {
    // Wait for steps to be visible
    await page.waitForSelector('.steps', { timeout: 10000 })

    // First step should be active
    const firstStep = page.locator('.step-item').nth(0)
    await expect(firstStep).toHaveClass(/active/)

    // Other steps should not be active or completed
    const secondStep = page.locator('.step-item').nth(1)
    const thirdStep = page.locator('.step-item').nth(2)

    // Check that step 2 and 3 are not active
    await expect(secondStep).not.toHaveClass(/active/)
    await expect(thirdStep).not.toHaveClass(/active/)
  })

  test('should show form action buttons', async ({ page }) => {
    // Wait for form actions to be visible
    await page.waitForSelector('.form-actions', { timeout: 10000 })

    // Check that action buttons container exists
    await expect(page.locator('.form-actions')).toBeVisible()

    // On step 1, only next button should be visible (no back button)
    const backButton = page.locator('.form-actions .app-button:has-text("上一步")')
    await expect(backButton).not.toBeVisible()

    // Next button should be visible but disabled
    const nextButton = page.locator('.form-actions .app-button:has-text("下一步")')
    await expect(nextButton).toBeVisible()
  })

  test('should display form tips and hints', async ({ page }) => {
    // Wait for form to be ready
    await page.waitForSelector('.form-body', { timeout: 10000 })

    // Check that form tips exist
    const formTips = page.locator('.form-tip')
    await expect(formTips.first()).toBeVisible()
  })

  test('should have proper form structure', async ({ page }) => {
    // Wait for form to be ready
    await page.waitForSelector('.form-card', { timeout: 10000 })

    // Check form structure
    await expect(page.locator('.card-header')).toBeVisible()
    await expect(page.locator('.form-body')).toBeVisible()

    // Check form items exist
    const formItems = page.locator('.form-item')
    const count = await formItems.count()
    expect(count).toBeGreaterThan(0)
  })
})
