# Categories

## Overview

Categories allow you to organize your income and expenses for better financial tracking and reporting.

## Default Categories

The app comes with pre-defined default categories:

### Expense Categories

- Food & Dining
- Transportation
- Shopping
- Entertainment
- Bills & Utilities
- Health & Fitness
- Education
- Travel
- Personal Care
- Gifts & Donations
- Other

### Income Categories

- Salary
- Freelance
- Investments
- Gifts
- Other Income

## Custom Categories

### Creating Custom Categories

1. Navigate to the categories section from the settings or transaction form
2. Tap "Add Category"
3. Enter category name
4. Choose an icon from the available set
5. Select a color for visual identification

### Category Properties

- **Name**: Descriptive label for the category
- **Icon**: Visual identifier from Material Icons
- **Color**: Hex color code for visual distinction
- **Type**: Income or Expense

## Managing Categories

### Editing Categories

Tap on any category to modify its name, icon, or color.

### Deleting Categories

When deleting a category:
- Transactions using that category will need reassignment
- The category is permanently removed

## Category Data Model

```
Category {
  id: String
  name: String
  icon: String (Material Icon name)
  color: int (color value)
  type: CategoryType (income/expense)
  isDefault: bool
  createdAt: DateTime
}
```

## Related Features

- [Transactions](transactions.rst)
- [Budget Management](budget_management.rst)
