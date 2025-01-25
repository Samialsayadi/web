""" Command-line interface for the application. """

# pylint: disable=no-value-for-parameter

import asyncio

import click

from placeholder.config import OUTPUT_FILE_PATH
from placeholder.main import main


@click.command()
@click.argument("source", type=str, default=".")
@click.option("--output", "-o", default=None, help="Output file path (default: <repo_name>.txt in current directory)")
@click.option("--branch", "-b", default=None, help="Branch to clone and ingest")
def cli(
    source: str,
    output: str | None,
    branch: str | None
):
    """
    Main entry point for the CLI. This function is called when the CLI is run as a script.

    It calls the async main function to run the command.

    Parameters
    ----------
    source : str
        The source directory or repository to analyze.
    output : str | None
        The path where the output file will be written. If not specified, the output will be written
        to a file named `<repo_name>.txt` in the current directory.
    branch : str | None
        The branch to clone (optional).
    """
    # Main entry point for the CLI. This function is called when the CLI is run as a script.
    asyncio.run(_async_cli(source, output, branch))

async def _async_cli(
    source: str,
    output: str | None,
    branch: str | None,
) -> None:
    """
    Analyze a directory or repository and create a text dump of its contents.

    This command analyzes the contents of a specified source directory or repository, applies custom include and
    exclude patterns, and generates a text summary of the analysis which is then written to an output file.

    Parameters
    ----------
    source : str
        The source directory or repository to analyze.
    output : str | None
        The path where the output file will be written. If not specified, the output will be written
        to a file named `<repo_name>.txt` in the current directory.
    branch : str | None
        The branch to clone (optional).

    Raises
    ------
    Abort
        If there is an error during the execution of the command, this exception is raised to abort the process.
    """
    try:

        if not output:
            output = OUTPUT_FILE_PATH
            result = main(source, output=output)

        click.echo(f"Analysis complete! Output written to: {output}")
        click.echo("\nSummary:")
        click.echo(result)

    except Exception as e:
        click.echo(f"Error: {e}", err=True)
        raise click.Abort()


if __name__ == "__main__":
    main()
