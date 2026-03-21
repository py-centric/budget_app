# Sphinx configuration for Invoice Dashboard & Payables

import os
import sys

sys.path.insert(0, os.path.abspath("."))

project = "Invoice Dashboard & Payables"
copyright = "2026"
author = ""

extensions = [
    "sphinx.ext.autodoc",
    "sphinx.ext.viewcode",
    "sphinx.ext.napoleon",
]

templates_path = ["_templates"]
exclude_patterns = ["_build", "Thumbs.db", ".DS_Store"]

html_theme = "sphinx_rtd_theme"
html_static_path = ["_static"]
