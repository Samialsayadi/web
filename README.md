# Gitemplate

A modern, production-ready template for FastAPI projects with Jinja2 templating and TailwindCSS styling. Skip the boring part and get straight to building your next web application!

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.109.0-009688.svg)](https://fastapi.tiangolo.com)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)

## Features

- **Production-Ready Structure**: Organized project layout following best practices
- **Modern Stack**: FastAPI, Jinja2, and TailwindCSS integration
- **Developer Experience**: 
  - Pre-configured development tools (Black, isort, pylint)
  - Hot-reload for development
  - Type hints and comprehensive docstrings
- **Template System**: 
  - Easy customization through `template.yaml`
  - Automatic placeholder replacement
  - Smart Jinja2 template handling
- **Security**: 
  - Built-in rate limiting
  - Trusted host middleware
  - Security headers configuration
- **Deployment Ready**:
  - Docker support
  - GitHub Actions workflow for PyPI publishing
  - Health check endpoints

## Quick Start

1. Use this template by clicking "Use this template" on GitHub or clone it:

"""
git clone https://github.com/atyrode/gitemplate.git
cd gitemplate
"""

2. Set up your project details in `template.yaml`:

"""
author: "Your Name"
package_name: "your_package"
project_name: "Your Project"
# ... (see template.yaml for all options)
"""

3. Apply the template:

"""
chmod +x apply_template.sh
./apply_template.sh
"""

4. Install dependencies:

"""
python -m venv .venv
source .venv/bin/activate  # On Windows: `.venv\Scripts\activate`
pip install -r requirements-dev.txt
pre-commit install
"""

5. Run the development server:

"""
cd src
python -m uvicorn app:app --reload --host 0.0.0.0 --port 8000
"""

Visit `http://localhost:8000` to see your application running!

## Project Structure

"""
├── src/
│   ├── static/          # Static files (CSS, JS, images)
│   ├── templates/       # Jinja2 templates
│   ├── routers/         # FastAPI route modules
│   ├── config.py        # Configuration settings
│   └── main.py         # FastAPI application entry point
├── tests/              # Test files
├── Dockerfile         # Docker configuration
├── requirements.txt   # Production dependencies
└── requirements-dev.txt  # Development dependencies
"""

## Development

### Running Tests

"""
pytest
"""

### Code Formatting

The project uses pre-commit hooks to maintain code quality:

"""
# Format code
black .

# Sort imports
isort .

# Lint code
pylint src/
"""

### Docker Support

Build and run using Docker:

"""
docker build -t your-app-name .
docker run -p 8000:8000 your-app-name
"""

## Customization

1. Update `template.yaml` with your project details
2. Modify Jinja2 templates in `src/templates/`
3. Add routes in `src/routers/`
4. Customize styling using TailwindCSS classes

## Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) for details on how to submit pull requests, report issues, and contribute to the project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [FastAPI](https://fastapi.tiangolo.com/) for the amazing web framework
- [Jinja2](https://jinja.palletsprojects.com/) for templating
- [TailwindCSS](https://tailwindcss.com/) for styling