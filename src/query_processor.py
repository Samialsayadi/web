""" Process a query by parsing input, cloning a repository, and generating a summary. """

from functools import partial

from fastapi import Request
from fastapi.templating import Jinja2Templates
from starlette.templating import _TemplateResponse

from config import EXAMPLE_REPOS
from placeholder.query_parser import ParsedQuery, parse_query
from placeholder.repository_clone import CloneConfig, clone_repo
from server_utils import Colors

templates = Jinja2Templates(directory="templates")


async def process_query(
    request: Request,
    input_text: str,
    is_index: bool = False,
) -> _TemplateResponse:
    """
    Process a query received from the user.

    Parameters
    ----------
    request : Request
        The HTTP request object.
    input_text : str
        Input text provided by the user, typically a Git repository URL or slug.
    is_index : bool
        Flag indicating whether the request is for the index page (default is False).

    Returns
    -------
    _TemplateResponse
        Rendered template response containing the processed results or an error message.

    Raises
    ------
    ValueError
        If an invalid pattern type is provided.
    """

    template = "index.jinja" if is_index else "git.jinja"
    template_response = partial(templates.TemplateResponse, name=template)

    context = {
        "request": request,
        "repo_url": input_text,
        "examples": EXAMPLE_REPOS if is_index else [],
    }

    try:
        parsed_query: ParsedQuery = await parse_query(
            source=input_text,
            from_web=True,
        )
        if not parsed_query.url:
            raise ValueError("The 'url' parameter is required.")

        clone_config = CloneConfig(
            url=parsed_query.url,
            local_path=str(parsed_query.local_path),
            commit=parsed_query.commit,
            branch=parsed_query.branch,
        )
        await clone_repo(clone_config)
        summary, tree, content = ... # TODO: Implement your idea
        with open(f"{clone_config.local_path}.txt", "w", encoding="utf-8") as f:
            f.write(tree + "\n" + content)
    except Exception as e:
        # hack to print error message when query is not defined
        if "query" in locals() and parsed_query is not None and isinstance(parsed_query, dict):
            _print_error(parsed_query["url"], e)
        else:
            print(f"{Colors.BROWN}WARN{Colors.END}: {Colors.RED}<-  {Colors.END}", end="")
            print(f"{Colors.RED}{e}{Colors.END}")

        context["error_message"] = f"Error: {e}"
        return template_response(context=context)

    _print_success(
        url=parsed_query.url,
    )

    context.update(
        {
            "result": True,
            "summary": summary,
            "tree": tree,
            "content": content,
            "ingest_id": parsed_query.id,
        }
    )

    return template_response(context=context)


def _print_error(url: str, e: Exception) -> None:
    """
    Print a formatted error message.

    Parameters
    ----------
    url : str
        The URL associated with the query that caused the error.
    e : Exception
        The exception raised during the query or process.
    """
    ...


def _print_success(url: str) -> None:
    """
    Print a formatted success message.

    Parameters
    ----------
    url : str
        The URL associated with the successful query.
    """
    ...
