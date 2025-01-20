""" Configuration file for the project. """

from pathlib import Path

MAX_FILE_SIZE = 10 * 1024 * 1024  # 10 MB
MAX_DIRECTORY_DEPTH = 20  # Maximum depth of directory traversal
MAX_FILES = 10_000  # Maximum number of files to process
MAX_TOTAL_SIZE_BYTES = 500 * 1024 * 1024  # 500 MB

MAX_DISPLAY_SIZE: int = 300_000
TMP_BASE_PATH = Path("/tmp/{{ package_name }}")
DELETE_REPO_AFTER: int = 60 * 60  # In seconds
