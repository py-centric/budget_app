"""
Budget App Feature Tests using WebCrawler Python API

This test verifies that key features of the budget app are accessible
and functional in the web interface.

Prerequisites:
1. Flutter web app running at http://localhost:8080
2. WebCrawler installed: cd submodules/WebCrawler && uv sync

Run:
    cd /home/v/Projects/budget_app/submodules/WebCrawler
    uv run python /home/v/Projects/budget_app/budget_app/tests/wc/test_features.py
"""

import asyncio
import os
from pathlib import Path

# Add the WebCrawler to the path
import sys
sys.path.insert(0, str(Path(__file__).parent.parent.parent / "submodules" / "WebCrawler"))

from web_crawler import WebCrawler


async def test_features():
    """Test specific features of the budget app."""
    
    # Create output directory
    os.makedirs("/tmp/budget_app", exist_ok=True)
    
    async with WebCrawler(headless=False) as crawler:
        print("=== Budget App Feature Tests ===")
        
        # Navigate to the app
        await crawler.goto("http://localhost:8080")
        await crawler.wait_for_load_state("domcontentloaded")
        await asyncio.sleep(2)
        
        # Test 1: Home Page
        print("\n--- Test 1: Home Page ---")
        await crawler.screenshot("/tmp/budget_app/features_01_home.png")
        
        # Check for navigation elements
        buttons = await crawler.find("flt-semantics[role='button']")
        print(f"  Navigation buttons: {len(buttons) if buttons else 0}")
        
        # Test 2: Navigation
        print("\n--- Test 2: Navigation ---")
        links = await crawler.find("flt-semantics[role='link']")
        print(f"  Links found: {len(links) if links else 0}")
        
        # Test 3: Form Elements
        print("\n--- Test 3: Form Elements ---")
        inputs = await crawler.find("flt-semantics[role='textbox']")
        print(f"  Text inputs: {len(inputs) if inputs else 0}")
        
        dropdowns = await crawler.find("flt-semantics[role='listbox']")
        print(f"  Dropdowns: {len(dropdowns) if dropdowns else 0}")
        
        # Test 4: Interactive Elements
        print("\n--- Test 4: Interactive Elements ---")
        checkboxes = await crawler.find("flt-semantics[role='checkbox']")
        print(f"  Checkboxes: {len(checkboxes) if checkboxes else 0}")
        
        switches = await crawler.find("flt-semantics[role='switch']")
        print(f"  Switches: {len(switches) if switches else 0}")
        
        # Test 5: Lists
        print("\n--- Test 5: Lists ---")
        lists = await crawler.find("flt-semantics[role='list']")
        print(f"  Lists: {len(lists) if lists else 0}")
        
        # Test 6: Page Structure
        print("\n--- Test 6: Page Structure ---")
        all_semantics = await crawler.find("flt-semantics")
        print(f"  Total semantic elements: {len(all_semantics) if all_semantics else 0}")
        
        # Take a final screenshot
        await crawler.screenshot("/tmp/budget_app/features_02_final.png", full_page=True)
        
        # Print summary
        print("\n=== Summary ===")
        title = await crawler.get_title()
        url = await crawler.get_url()
        print(f"  Title: {title}")
        print(f"  URL: {url}")
        
        # Check for errors
        error_count = await crawler.get_variable("error_count")
        if error_count and error_count != "0":
            print(f"  Errors: {error_count}")
        else:
            print("  Status: PASS")
        
        print("\n=== Tests Complete ===")


if __name__ == "__main__":
    asyncio.run(test_features())
