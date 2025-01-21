""" Configuration file for the project. """

# TODO: Remove this when core src are removed
from pathlib import Path
TMP_BASE_PATH = Path("...")

EXAMPLE_REPOS: list[dict[str, str]] = [
    {"name": "Gitingest", "url": "https://github.com/cyclotruc/gitingest"},
    {"name": "FastAPI", "url": "https://github.com/tiangolo/fastapi"},
    {"name": "Tldraw", "url": "https://github.com/tldraw/tldraw"},
]