""" Process a query by parsing input, cloning a repository, and generating a summary. """

from functools import partial

from fastapi import Request
from fastapi.templating import Jinja2Templates
from starlette.templating import _TemplateResponse

from placeholder.query_ingestion import run_ingest_query
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
    Process a query

    Parameters
    ----------
    request : Request
        The HTTP request object.
    input_text : str
        Input text provided by the user.
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
        "input_text": input_text,
    }

    # TODO: Implement everything

    context.update(
        {
            "result": True,
        }
    )

    return template_response(context=context)



def _print_error() -> None:
    """
    Print a formatted error message

    Parameters
    ----------
    
    """


def _print_success() -> None:
    """
    Print a formatted success message

    Parameters
    ----------

    """
