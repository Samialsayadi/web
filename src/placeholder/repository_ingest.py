""" Main entry point for ingesting a source and processing its contents. """

import asyncio
import inspect
import shutil

from config import TMP_BASE_PATH
from placeholder.query_parser import ParsedQuery, parse_query
from placeholder.repository_clone import CloneConfig, clone_repo


async def ingest(
    source: str,
    output: str | None = None,
) -> tuple[str, str, str]:
    """
    Main entry point for ingesting a source and processing its contents.

    This function analyzes a source (URL or local path), clones the corresponding repository (if applicable),
    and processes its files according to the specified query parameters. It returns a summary, a tree-like
    structure of the files, and the content of the files. The results can optionally be written to an output file.

    Parameters
    ----------
    source : str
        The source to analyze, which can be a URL (for a Git repository) or a local directory path.
    output : str | None, optional
        File path where the summary and content should be written. If `None`, the results are not written to a file.

    Returns
    -------
    tuple[str, str, str]
        A tuple containing:
        - A summary string of the analyzed repository or directory.
        - A tree-like string representation of the file structure.
        - The content of the files in the repository or directory.

    Raises
    ------
    TypeError
        If `clone_repo` does not return a coroutine, or if the `source` is of an unsupported type.
    """
    try:
        parsed_query: ParsedQuery = await parse_query(
            source=source,
            from_web=False,
        )

        if parsed_query.url:
            # Extract relevant fields for CloneConfig
            clone_config = CloneConfig(
                url=parsed_query.url,
                local_path=str(parsed_query.local_path),
                commit=parsed_query.commit,
                branch=parsed_query.branch,
            )
            clone_result = clone_repo(clone_config)

            if inspect.iscoroutine(clone_result):
                asyncio.run(clone_result)
            else:
                raise TypeError("clone_repo did not return a coroutine as expected.")

        summary, tree, content = "", "", ""

        if output is not None:
            with open(output, "w", encoding="utf-8") as f:
                f.write(tree + "\n" + content)

        return summary, tree, content
    finally:
        # Clean up the temporary directory if it was created
        if parsed_query.url:
            # Clean up the temporary directory
            shutil.rmtree(TMP_BASE_PATH, ignore_errors=True)
