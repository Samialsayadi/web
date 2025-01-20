""" Configuration file for the project. """

MAX_FILE_SIZE = 10 * 1024 * 1024  # 10 MB
MAX_DIRECTORY_DEPTH = 20  # Maximum depth of directory traversal
MAX_FILES = 10_000  # Maximum number of files to process
MAX_TOTAL_SIZE_BYTES = 500 * 1024 * 1024  # 500 MB

EXAMPLE_REPOS: list[dict[str, str]] = [
    {"name": "Gitingest", "url": "https://github.com/cyclotruc/gitingest"},
    {"name": "FastAPI", "url": "https://github.com/tiangolo/fastapi"},
    {"name": "Flask", "url": "https://github.com/pallets/flask"},
    {"name": "Tldraw", "url": "https://github.com/tldraw/tldraw"},
    {"name": "ApiAnalytics", "url": "https://github.com/tom-draper/api-analytics"},
]