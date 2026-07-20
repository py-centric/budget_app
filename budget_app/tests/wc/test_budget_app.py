"""
Budget App UI Test using WebCrawler Python API

This test demonstrates how to use the WebCrawler Python API
to test the budget app's web interface.

Prerequisites:
1. Flutter web app running at http://localhost:8080
2. WebCrawler installed: cd submodules/WebCrawler && uv sync

Run:
    cd /home/v/Projects/budget_app/submodules/WebCrawler
    uv run python /home/v/Projects/budget_app/budget_app/tests/wc/test_budget_app.py
"""

import asyncio
import os
from pathlib import Path

# Add the WebCrawler to the path
import sys
sys.path.insert(0, str(Path(__file__).parent.parent.parent / "submodules" / "WebCrawler"))

from web_crawler import WebCrawler


async def test_budget_app():
    """Test the budget app's web interface."""
    
    # Create output directory
    os.makedirs("/tmp/budget_app", exist_ok=True)
    
    async with WebCrawler(headless=False) as crawler:
        print("=== Budget App UI Test ===")
        
        # Test 1: Navigate to the app
        print("\nTest 1: Navigate to the app")
        await crawler.goto("http://localhost:8080")
        await crawler.wait_for_load_state("domcontentloaded")
        
        # Wait for Flutter to render
        await asyncio.sleep(2)
        
        # Take a screenshot
        await crawler.screenshot("/tmp/budget_app/test_01_initial.png")
        print("  Screenshot saved: /tmp/budget_app/test_01_initial.png")
        
        # Test 2: Check for semantic elements
        print("\nTest 2: Check for semantic elements")
        try:
            elements = await crawler.find("flt-semantics")
            if elements:
                print(f"  PASS: Found {len(elements)} semantic elements")
            else:
                print("  FAIL: No semantic elements found")
        except Exception as e:
            print(f"  ERROR: {e}")
        
        # Test 3: Check for buttons
        print("\nTest 3: Check for buttons")
        try:
            buttons = await crawler.find("flt-semantics[role='button']")
            if buttons:
                print(f"  PASS: Found {len(buttons)} buttons")
            else:
                print("  INFO: No buttons found")
        except Exception as e:
            print(f"  ERROR: {e}")
        
        # Test 4: Check for text inputs
        print("\nTest 4: Check for text inputs")
        try:
            inputs = await crawler.find("flt-semantics[role='textbox']")
            if inputs:
                print(f"  PASS: Found {len(inputs)} text inputs")
            else:
                print("  INFO: No text inputs found")
        except Exception as e:
            print(f"  ERROR: {e}")
        
        # Test 5: Check for links
        print("\nTest 5: Check for links")
        try:
            links = await crawler.find("flt-semantics[role='link']")
            if links:
                print(f"  PASS: Found {len(links)} links")
            else:
                print("  INFO: No links found")
        except Exception as e:
            print(f"  ERROR: {e}")
        
        # Test 6: Take a full page screenshot
        print("\nTest 6: Full page screenshot")
        await crawler.screenshot("/tmp/budget_app/test_02_full_page.png", full_page=True)
        print("  Screenshot saved: /tmp/budget_app/test_02_full_page.png")
        
        # Test 7: Extract page title
        print("\nTest 7: Page information")
        title = await crawler.get_title()
        url = await crawler.get_url()
        print(f"  Title: {title}")
        print(f"  URL: {url}")
        
        # Test 8: Check for errors
        print("\nTest 8: Error check")
        error_count = await crawler.get_variable("error_count")
        if error_count and error_count != "0":
            print(f"  FAIL: Errors found: {error_count}")
        else:
            print("  PASS: No errors")
        
        print("\n=== Test Complete ===")


if __name__ == "__main__":
    asyncio.run(test_budget_app())
