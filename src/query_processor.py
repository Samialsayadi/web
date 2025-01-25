""" Process a query by parsing input, cloning a repository, and generating a summary. """

from functools import partial

from fastapi import Request
from fastapi.templating import Jinja2Templates
from starlette.templating import _TemplateResponse

from config import EXAMPLE_REPOS
from placeholder.main import main
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
    """

    template = "index.jinja" if is_index else "git.jinja"
    template_response = partial(templates.TemplateResponse, name=template)

    context = {
        "request": request,
        "repo_url": input_text,
        "examples": EXAMPLE_REPOS if is_index else [],
    }

    try:
        result = await main(input_text)
    except Exception as e:
        context["error_message"] = f"Error: {e}"
        return template_response(context=context)

    _print_success(
        url=input_text,
    )

    context.update(
        {
            "result": result,
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
    print(f"{Colors.RED}URL: {url}\nError: {e}{Colors.END}")


def _print_success(url: str) -> None:
    """
    Print a formatted success message.

    Parameters
    ----------
    url : str
        The URL associated with the successful query.
    """
    print(f"{Colors.GREEN}Success: {url}{Colors.END}")
