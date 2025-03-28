from pathlib import Path

from jinja2 import Environment, FileSystemLoader
from pydantic import BaseModel, Field, FilePath


class JinjaContext(BaseModel): ...


class JinjaTemplate(BaseModel):

    context: JinjaContext = Field(description="Context for the Jinja template")
    template_path: FilePath = Field(description="Path to the Jinja template file")
    output_path: FilePath = Field(description="Path where the rendered file will be saved")

    def render(self) -> str:

        # Get the template directory and filename
        template_path = Path(self.template_path)
        template_dir = template_path.parent
        template_file = template_path.name

        # Create environment with the correct template directory
        env = Environment(loader=FileSystemLoader(str(template_dir)))
        template = env.get_template(template_file)

        # Render the template
        rendered = template.render(self.context.model_dump_json())

        # Ensure output directory exists
        output_path = Path(self.output_path)
        output_path.parent.mkdir(parents=True, exist_ok=True)

        # Write the rendered content
        output_path.write_text(rendered)

        return rendered


class Module(BaseModel):
    id: str = Field(description="Name of the module (snake case) - must be set by child classes")
    enabled: bool = Field(default=False, description="Whether the module is enabled for the templating system")
    templates: list[JinjaTemplate] = Field(description="List of files to be rendered by the module")

    def build(self) -> None:
        for template in self.templates:
            template.render()


class Project(BaseModel):
    root_path: FilePath = Field(description="Path to the root of the project")
    modules: list[Module] = Field(description="List of modules to be rendered by the project")
