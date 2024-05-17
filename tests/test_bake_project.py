# pylint: disable=redefined-outer-name
# pylint: disable=unused-argument
# pylint: disable=unused-variable

import subprocess


from pytest_cookies.plugin import Cookies, Result
import pytest

def test_minimal_config_to_bake(cookies: Cookies):
    result = cookies.bake(extra_context={
            "project_slug": "test_project"})
    assert result is not None
    assert result.exit_code == 0
    assert result.exception is None
    assert result.project.basename == "test_project"

    print(f"{result}", f"{result.context=}")


@pytest.mark.parametrize(
    "commands_on_baked_project",
    (
        "ls -la .; make help",
        # TODO: cannot use `source` to activate venvs ... not sure how to proceed here. Suggestions?
        ## "make devenv; source .venv/bin/activate && make build info-build test",
    ),
)
def test_make_workflows(baked_project: Result, commands_on_baked_project: str):
    working_dir = baked_project.project_path
    subprocess.run(
        ["/bin/bash", "-c", commands_on_baked_project], cwd=working_dir, check=True
    )

