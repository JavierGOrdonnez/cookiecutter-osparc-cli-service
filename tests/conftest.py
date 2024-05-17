import json

import sys
from pathlib import Path

import pytest
from pytest_cookies.plugin import Cookies, Result

current_dir = Path(sys.argv[0] if __name__ == "__main__" else __file__).resolve().parent
repo_basedir =current_dir.parent
cookiecutter_json = repo_basedir / "cookiecutter.json"

@pytest.fixture
def baked_project(cookies: Cookies) -> Result:
    result = cookies.bake(
        extra_context={
            "project_slug": "test-touch-command",
            "project_name": "test-touch-command",
            "default_docker_registry": "test.test.com",
            "author_email": "test@project.org"
        }
    )

    assert result.exception is None
    assert result.exit_code == 0
    return result