#!/usr/bin/env python3
"""
Template configuration and setup script.
This script combines template configuration and project setup into a single tool.
"""

import argparse
import re
import subprocess
import sys
import venv
from dataclasses import dataclass, field
from pathlib import Path
from typing import List

from rich.console import Console
from rich.prompt import Confirm, Prompt

console = Console()


@dataclass
class TemplateConfig:
    """Template configuration with default values."""

    # Repository
    author: str = field(default="Your Name")
    author_email: str = field(default="your.email@example.com")
    author_social: str = field(default="https://your-social-link.com")
    author_nickname: str = field(default="@your_nickname")
    security_email: str = field(default="your.email@example.com")
    github_username: str = field(default="your_github_username")
    github_repository: str = field(default="your_github_repository")

    # Package
    package_name: str = field(default="your_package_name")
    package_version: str = field(default="0.1.0")
    package_description: str = field(default="A brief description of your package")
    package_keywords: str = field(
        default="AI tools, LLM integration, Context, Prompt, Git workflow, Git repository, Git automation, prompt-friendly"
    )

    # Project
    project_name: str = field(default="Projectname")
    project_url: str = field(default="https://your-project-url.com")
    project_domain: str = field(default="your-project-domain.com")
    chrome_extension_url: str = field(default="https://chromewebstore.google.com/detail/example")
    firefox_extension_url: str = field(default="https://addons.mozilla.org/firefox/addon/example")
    edge_extension_url: str = field(default="https://microsoftedge.microsoft.com/addons/detail/example")
    discord_invite: str = field(default="https://discord.com/invite/example")
    project_description: str = field(default="A description of your project, will appear at the top of the README.md")
    project_badges: str = field(
        default="""
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![PyPI version](https://badge.fury.io/py/example.svg)](https://badge.fury.io/py/example)
[![GitHub stars](https://img.shields.io/github/stars/example?style=social)](https://github.com/example)
[![Downloads](https://pepy.tech/badge/example)](https://pepy.tech/project/example)
""".strip()
    )
    project_features: str = field(default="Describe the features of the project")
    project_stack: str = field(default="Stack used for the project")
    project_command_line_usage: str = field(default="Describes the steps to use the command line tool")
    project_python_package_usage: str = field(default="Describes the steps to use the Python package")
    project_self_host_steps: str = field(default="Describes the steps to self-host the project")
    project_extension_informations: str = field(
        default="This flavor text will appear in the README.md file under the extension badges"
    )

    # Files to be processed
    templated_files: list[str] = field(
        default_factory=lambda: [
            "README.md",
            "pyproject.toml",
            "SECURITY.md",
            "LICENSE",
            "CONTRIBUTING.md",
            "src/static/robots.txt",
            "src/placeholder/query_processor.py",
            "src/placeholder/__init__.py",
            "src/server/templates/base.jinja",
            "src/server/templates/components/footer.jinja",
            "src/server/templates/components/navbar.jinja",
            "src/server/templates/api.jinja",
        ]
    )

    def interactive_setup(self) -> None:
        """Interactive configuration setup."""
        console.rule("[bold blue]Interactive Configuration Setup")

        self.author = Prompt.ask("Author name", default=self.author)
        self.author_email = Prompt.ask("Author email", default=self.author_email)
        self.github_username = Prompt.ask("GitHub username", default=self.github_username)
        self.github_repository = Prompt.ask("GitHub repository", default=self.github_repository)
        self.package_name = Prompt.ask("Package name", default=self.package_name)
        self.project_name = Prompt.ask("Project name", default=self.project_name)
        self.package_description = Prompt.ask("Project description", default=self.package_description)
        self.project_url = Prompt.ask("Project URL", default=self.project_url)


class TemplateProcessor:
    def __init__(self, config: TemplateConfig, auto_yes: bool = False):
        self.config = config
        self.auto_yes = auto_yes

    def process_files(self) -> None:
        """Process all template files."""
        console.rule("[bold blue]Processing template files")

        # Handle template README first
        template_readme = Path("template_README.md")
        if template_readme.exists():
            console.print("[yellow]Found template_README.md, replacing README.md...[/yellow]")
            if Path("README.md").exists():
                Path("README.md").rename("README.old.md")
                console.print("[yellow]Backed up existing README.md to README.old.md[/yellow]")
            template_readme.rename("README.md")
            console.print("[green]✓ Replaced[/green] README.md with template version")

        for file_path in self.config.templated_files:
            path = Path(file_path)
            if not path.exists():
                console.print(f"[red]✗ File not found:[/red] {file_path}")
                continue

            console.print(f"[green]Processing[/green] {file_path}")
            self._process_file(path)

        # Rename placeholder directory
        placeholder_dir = Path("src/placeholder")
        if placeholder_dir.exists():
            new_dir = Path(f"src/{self.config.package_name}")
            placeholder_dir.rename(new_dir)
            console.print(f"[green]✓ Renamed[/green] {placeholder_dir} to {new_dir}")

            # Update imports in all Python files
            for py_file in Path("src").rglob("*.py"):
                self._update_imports(py_file)

    def _process_file(self, file_path: Path) -> None:
        """Process a single template file."""
        content = file_path.read_text()

        # Handle Jinja templates
        if file_path.suffix == ".jinja":
            pattern = r"{!{\s*(\w+)\s*}!}"
            repl = lambda m: getattr(self.config, m.group(1), m.group(0))
        else:
            pattern = r"{{\s*(\w+)\s*}}"
            repl = lambda m: getattr(self.config, m.group(1), m.group(0))

        content = re.sub(pattern, repl, content)
        file_path.write_text(content)

    def _update_imports(self, file_path: Path) -> None:
        """Update Python imports in a file."""
        content = file_path.read_text()
        replacements = [
            (r"from placeholder\.", f"from {self.config.package_name}."),
            (r"import placeholder", f"import {self.config.package_name}"),
            (r"from server\.", f"from {self.config.package_name}.server."),
        ]

        for pattern, replacement in replacements:
            content = re.sub(pattern, replacement, content)

        file_path.write_text(content)


class ProjectSetup:
    def __init__(self, auto_yes: bool = False):
        self.auto_yes = auto_yes

    def setup_environment(self) -> None:
        """Set up the development environment."""
        console.rule("[bold blue]Setting up development environment")

        # Create virtual environment
        venv_path = Path("venv")
        if not venv_path.exists():
            console.print("[yellow]Creating virtual environment...[/yellow]")
            venv.create(venv_path, with_pip=True)

        # Determine activation script
        if sys.platform == "win32":
            activate_script = venv_path / "Scripts" / "activate"
        else:
            activate_script = venv_path / "bin" / "activate"

        # Install dependencies
        console.print("[yellow]Installing dependencies...[/yellow]")
        pip_cmd = [sys.executable, "-m", "pip", "install", "--upgrade", "pip"]
        subprocess.run(pip_cmd, check=True)

        if Path("requirements-dev.txt").exists():
            req_file = "requirements-dev.txt"
        else:
            req_file = "requirements.txt"

        if Path(req_file).exists():
            install_cmd = [sys.executable, "-m", "pip", "install", "-r", req_file]
            subprocess.run(install_cmd, check=True)

        # Install pre-commit hooks
        if Path(".pre-commit-config.yaml").exists():
            console.print("[yellow]Installing pre-commit hooks...[/yellow]")
            subprocess.run(["pre-commit", "install"], check=True)


def main():
    parser = argparse.ArgumentParser(description="Template configuration and setup tool")
    parser.add_argument("-y", "--yes", action="store_true", help="Auto-accept all prompts")
    parser.add_argument("-i", "--interactive", action="store_true", help="Run interactive configuration setup")
    args = parser.parse_args()

    try:
        # Create configuration with default values
        config = TemplateConfig()

        # Run interactive setup if requested
        if args.interactive:
            config.interactive_setup()

        # Preview configuration
        console.rule("[bold blue]Template Configuration")
        console.print(f"[bold]Project Details:[/bold]")
        console.print(f"  Project Name: {config.project_name}")
        console.print(f"  Package Name: {config.package_name}")
        console.print(f"  Description: {config.package_description}")
        console.print(f"\n[bold]Author Details:[/bold]")
        console.print(f"  Author: {config.author}")
        console.print(f"  GitHub: {config.github_username}")
        console.print(f"\n[bold]URLs:[/bold]")
        console.print(f"  Repository: {config.github_repository}")
        console.print(f"  Project URL: {config.project_url}")

        if not args.yes and not Confirm.ask("\nWould you like to apply this configuration?"):
            console.print("[yellow]Template application cancelled.[/yellow]")
            return

        # Process template files
        processor = TemplateProcessor(config, args.yes)
        processor.process_files()

        # Set up development environment
        setup = ProjectSetup(args.yes)
        setup.setup_environment()

        # Clean up template files
        if args.yes or Confirm.ask("\nWould you like to clean up template files?"):
            if Path("README.md.bak").exists():
                Path("README.md.bak").unlink()
            Path(__file__).unlink()
            console.print("[green]Template files cleaned up.[/green]")
        else:
            console.print("[yellow]Template files kept. You can delete them manually later.[/yellow]")

        console.print("\n[bold green]Template application completed![/bold green]")

    except Exception as e:
        console.print(f"[bold red]Error:[/bold red] {str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    main()
