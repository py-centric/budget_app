# Configuration file for the Sphinx documentation builder.

import os
from pathlib import Path

# -- Project information -----------------------------------------------------

project = "Budget App"
# Rendered in the HTML footer of every documentation page. Budget App is
# distributed under the GNU Affero General Public License v3.0; the full
# license text lives in the LICENSE file at the repository root.
copyright = "2026, PyCentric (Licensed under GNU AGPL-3.0)"
author = "PyCentric"
release = "1.1.0"

# -- General configuration ---------------------------------------------------

extensions = [
    "sphinx.ext.autodoc",
    "sphinx.ext.viewcode",
    "myst_parser",
    "sphinxcontrib.mermaid",
]

templates_path = ["_templates"]
exclude_patterns = [
    "_build",
    "Thumbs.db",
    ".DS_Store",
    "index_content.rst",
    "diagrams/*",
]

source_suffix = {
    ".rst": "restructuredtext",
    ".md": "markdown",
}

# -- Mermaid configuration ---------------------------------------------------
mermaid_output_format = "raw"
mermaid_version = "10.9.0"

# -- Options for HTML output -------------------------------------------------

html_theme = "alabaster"
html_title = "Budget App Documentation"

# -- Autodoc configuration --------------------------------------------------
autodoc_default_options = {
    "members": True,
    "member-order": "bysource",
    "special-members": "__init__",
    "undoc-members": True,
    "exclude-members": "__weakref__",
}
