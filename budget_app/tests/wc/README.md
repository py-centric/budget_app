# Budget App UI Tests (WebCrawler .wc files)

This directory contains UI test scripts written in the WebCrawler `.wc` DSL for testing the budget app's web interface.

## Prerequisites

1. **Flutter web app running** - Start the app in web mode:
   ```bash
   cd /home/v/Projects/budget_app/budget_app
   flutter run -d chrome --web-port=8080
   ```

2. **WebCrawler installed** - The Python submodule must be set up:
   ```bash
   cd /home/v/Projects/budget_app/submodules/WebCrawler
   uv sync
   ```

3. **Create output directory** - Screenshots are saved to `/tmp/budget_app/`:
   ```bash
   mkdir -p /tmp/budget_app
   ```

## Running Tests

### Run all tests
```bash
cd /home/v/Projects/budget_app/submodules/WebCrawler
uv run python __main__.py run /home/v/Projects/budget_app/budget_app/tests/wc/run_tests.wc --headed
```

### Run individual tests
```bash
cd /home/v/Projects/budget_app/submodules/WebCrawler

# Home page test
uv run python __main__.py run /home/v/Projects/budget_app/budget_app/tests/wc/home_page.wc --headed

# Navigation test
uv run python __main__.py run /home/v/Projects/budget_app/budget_app/tests/wc/navigation.wc --headed

# Budget flow test
uv run python __main__.py run /home/v/Projects/budget_app/budget_app/tests/wc/budget_flow.wc --headed

# Income/expense test
uv run python __main__.py run /home/v/Projects/budget_app/budget_app/tests/wc/income_expense.wc --headed

# Category management test
uv run python __main__.py run /home/v/Projects/budget_app/budget_app/tests/wc/category_management.wc --headed

# Settings test
uv run python __main__.py run /home/v/Projects/budget_app/budget_app/tests/wc/settings.wc --headed

# Comprehensive test
uv run python __main__.py run /home/v/Projects/budget_app/budget_app/tests/wc/comprehensive.wc --headed
```

### Run in headless mode (no browser window)
```bash
uv run python __main__.py run /home/v/Projects/budget_app/budget_app/tests/wc/home_page.wc
```

### Run with strict mode (abort on first error)
```bash
uv run python __main__.py run /home/v/Projects/budget_app/budget_app/tests/wc/home_page.wc --strict
```

### Validate only (no browser execution)
```bash
uv run python __main__.py run /home/v/Projects/budget_app/budget_app/tests/wc/home_page.wc --dry-run
```

## Test Files

| File | Description |
|------|-------------|
| `home_page.wc` | Tests the home page initial load and rendering |
| `navigation.wc` | Tests navigation between pages |
| `budget_flow.wc` | Tests the budget creation and management flow |
| `income_expense.wc` | Tests income and expense entry |
| `category_management.wc` | Tests category management |
| `settings.wc` | Tests the settings page |
| `comprehensive.wc` | Comprehensive UI test covering all major flows |
| `run_tests.wc` | Runs all test files in sequence |

## Flutter Web Selectors

Flutter web apps render using semantic elements for accessibility. The following selectors work with Flutter web:

### Semantic Elements
- `flt-semantics` - All semantic elements
- `flt-semantics[role='button']` - Buttons
- `flt-semantics[role='link']` - Links
- `flt-semantics[role='textbox']` - Text inputs
- `flt-semantics[role='listbox']` - Dropdowns
- `flt-semantics[role='checkbox']` - Checkboxes
- `flt-semantics[role='switch']` - Switches

### Text Content
Flutter renders text in semantic elements. You can find elements by their text content using the `text` selector.

## Output

Tests generate screenshots in `/tmp/budget_app/`:
- `home_page_initial.png` - Initial page load
- `home_page_loaded.png` - After Flutter renders
- `navigation_*.png` - Navigation test screenshots
- `budget_flow_*.png` - Budget flow screenshots
- `income_*.png` - Income/expense screenshots
- `category_*.png` - Category management screenshots
- `settings_*.png` - Settings screenshots
- `comprehensive_*.png` - Comprehensive test screenshots

## Troubleshooting

### No semantic elements found
If tests report "No semantic elements found", the Flutter app may be using Canvas renderer. Try running with HTML renderer:
```bash
flutter run -d chrome --web-port=8080 --web-renderer html
```

### Tests fail to connect
Make sure the Flutter web app is running on port 8080 before executing the tests.

### Screenshots are empty
If screenshots show a blank page, wait longer for Flutter to render. Increase the timeout in the `wait` statements.

## Integration with CI/CD

To run these tests in CI/CD:
1. Start the Flutter web app in the background
2. Wait for it to be ready
3. Run the `.wc` tests
4. Check the exit code (0 = success, 1 = parse error, 2 = runtime error in strict mode)

Example CI script:
```bash
# Start Flutter web app
flutter run -d chrome --web-port=8080 &
sleep 10

# Run tests
cd /home/v/Projects/budget_app/submodules/WebCrawler
uv run python __main__.py run /home/v/Projects/budget_app/budget_app/tests/wc/run_tests.wc --strict

# Check result
if [ $? -eq 0 ]; then
    echo "Tests passed"
else
    echo "Tests failed"
    exit 1
fi
```
