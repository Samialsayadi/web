# Mode:
# - Keep: Don't change anything, remove template files
# - Light: Only the most basic functionnalities
# - Full: All features
# - Custom: Only the features you want

# Modules:
# - Gitingest-similarity setup
# - Dockerfiles
# - Docker Compose
# - Pre-commit hooks
# - Pytest
# - Black
# - Isort
# - Flake8
# - Readme.md
# - Traefik
# - Rich
# - Pylint

from modules.docker.docker_compose.models import DockerCompose
from pydantic import BaseModel

docker_compose: BaseModel = DockerCompose()

# Output as output.json
with open("output.json", "w") as f:
    f.write(docker_compose.model_dump_json())
