"""
Budget App Comprehensive UI Test

This test provides comprehensive coverage of the budget app's web interface,
testing all major UI components and interactions.

Prerequisites:
1. Flutter web app running at http://localhost:8080
2. WebCrawler installed: cd submodules/WebCrawler && uv sync

Run:
    cd /home/v/Projects/budget_app/submodules/WebCrawler
    uv run python /home/v/Projects/budget_app/budget_app/tests/wc/test_comprehensive.py
"""

import asyncio
import os
from pathlib import Path

# Add the WebCrawler to the path
import sys
sys.path.insert(0, str(Path(__file__).parent.parent.parent / "submodules" / "WebCrawler"))

from web_crawler import WebCrawler


class BudgetAppTest:
    """Comprehensive test suite for the budget app."""
    
    def __init__(self, headless=False):
        self.headless = headless
        self.crawler = None
        self.results = []
    
    async def setup(self):
        """Initialize the test environment."""
        os.makedirs("/tmp/budget_app", exist_ok=True)
        self.crawler = WebCrawler(headless=self.headless)
        await self.crawler.start()
    
    async def teardown(self):
        """Clean up the test environment."""
        if self.crawler:
            await self.crawler.stop()
    
    def log_result(self, test_name, passed, message=""):
        """Log a test result."""
        status = "PASS" if passed else "FAIL"
        self.results.append({
            "test": test_name,
            "status": status,
            "message": message
        })
        print(f"  [{status}] {test_name}: {message}")
    
    async def test_home_page_loads(self):
        """Test that the home page loads successfully."""
        print("\n--- Test: Home Page Loads ---")
        
        try:
            await self.crawler.goto("http://localhost:8080")
            await self.crawler.wait_for_load_state("domcontentloaded")
            await asyncio.sleep(2)
            
            # Check that we're on the right URL
            url = await self.crawler.get_url()
            if "localhost:8080" in url:
                self.log_result("URL", True, f"Correct URL: {url}")
            else:
                self.log_result("URL", False, f"Wrong URL: {url}")
            
            # Check that Flutter rendered
            elements = await self.crawler.find("flt-semantics")
            if elements and len(elements) > 0:
                self.log_result("Flutter Render", True, f"Found {len(elements)} semantic elements")
            else:
                self.log_result("Flutter Render", False, "No semantic elements found")
            
            # Take screenshot
            await self.crawler.screenshot("/tmp/budget_app/test_home.png")
            
        except Exception as e:
            self.log_result("Home Page", False, str(e))
    
    async def test_navigation_elements(self):
        """Test that navigation elements are present."""
        print("\n--- Test: Navigation Elements ---")
        
        try:
            # Check for buttons
            buttons = await self.crawler.find("flt-semantics[role='button']")
            if buttons:
                self.log_result("Buttons", True, f"Found {len(buttons)} buttons")
            else:
                self.log_result("Buttons", False, "No buttons found")
            
            # Check for links
            links = await self.crawler.find("flt-semantics[role='link']")
            if links:
                self.log_result("Links", True, f"Found {len(links)} links")
            else:
                self.log_result("Links", False, "No links found")
            
        except Exception as e:
            self.log_result("Navigation", False, str(e))
    
    async def test_form_elements(self):
        """Test that form elements are present."""
        print("\n--- Test: Form Elements ---")
        
        try:
            # Check for text inputs
            inputs = await self.crawler.find("flt-semantics[role='textbox']")
            if inputs:
                self.log_result("Text Inputs", True, f"Found {len(inputs)} text inputs")
            else:
                self.log_result("Text Inputs", False, "No text inputs found")
            
            # Check for dropdowns
            dropdowns = await self.crawler.find("flt-semantics[role='listbox']")
            if dropdowns:
                self.log_result("Dropdowns", True, f"Found {len(dropdowns)} dropdowns")
            else:
                self.log_result("Dropdowns", False, "No dropdowns found")
            
        except Exception as e:
            self.log_result("Form Elements", False, str(e))
    
    async def test_interactive_elements(self):
        """Test that interactive elements are present."""
        print("\n--- Test: Interactive Elements ---")
        
        try:
            # Check for checkboxes
            checkboxes = await self.crawler.find("flt-semantics[role='checkbox']")
            if checkboxes:
                self.log_result("Checkboxes", True, f"Found {len(checkboxes)} checkboxes")
            else:
                self.log_result("Checkboxes", False, "No checkboxes found")
            
            # Check for switches
            switches = await self.crawler.find("flt-semantics[role='switch']")
            if switches:
                self.log_result("Switches", True, f"Found {len(switches)} switches")
            else:
                self.log_result("Switches", False, "No switches found")
            
        except Exception as e:
            self.log_result("Interactive Elements", False, str(e))
    
    async def test_page_structure(self):
        """Test the overall page structure."""
        print("\n--- Test: Page Structure ---")
        
        try:
            # Count all semantic elements
            all_semantics = await self.crawler.find("flt-semantics")
            if all_semantics:
                self.log_result("Semantic Elements", True, f"Found {len(all_semantics)} elements")
            else:
                self.log_result("Semantic Elements", False, "No semantic elements found")
            
            # Check for lists
            lists = await self.crawler.find("flt-semantics[role='list']")
            if lists:
                self.log_result("Lists", True, f"Found {len(lists)} lists")
            else:
                self.log_result("Lists", False, "No lists found")
            
        except Exception as e:
            self.log_result("Page Structure", False, str(e))
    
    async def test_error_handling(self):
        """Test that no errors occurred."""
        print("\n--- Test: Error Handling ---")
        
        try:
            error_count = await self.crawler.get_variable("error_count")
            if error_count and error_count != "0":
                self.log_result("Errors", False, f"Found {error_count} errors")
            else:
                self.log_result("Errors", True, "No errors found")
            
        except Exception as e:
            self.log_result("Error Handling", False, str(e))
    
    async def run_all_tests(self):
        """Run all tests."""
        print("=== Budget App Comprehensive UI Test ===")
        
        await self.setup()
        
        try:
            await self.test_home_page_loads()
            await self.test_navigation_elements()
            await self.test_form_elements()
            await self.test_interactive_elements()
            await self.test_page_structure()
            await self.test_error_handling()
            
            # Take final screenshot
            await self.crawler.screenshot("/tmp/budget_app/test_final.png", full_page=True)
            
        finally:
            await self.teardown()
        
        # Print summary
        print("\n=== Test Summary ===")
        passed = sum(1 for r in self.results if r["status"] == "PASS")
        failed = sum(1 for r in self.results if r["status"] == "FAIL")
        total = len(self.results)
        
        print(f"  Total: {total}")
        print(f"  Passed: {passed}")
        print(f"  Failed: {failed}")
        
        if failed > 0:
            print("\nFailed tests:")
            for r in self.results:
                if r["status"] == "FAIL":
                    print(f"  - {r['test']}: {r['message']}")
        
        print(f"\nOverall: {'PASS' if failed == 0 else 'FAIL'}")
        return failed == 0


async def main():
    """Main entry point."""
    test = BudgetAppTest(headless=False)
    success = await test.run_all_tests()
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    asyncio.run(main())
