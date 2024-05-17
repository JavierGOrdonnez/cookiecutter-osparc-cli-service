import os
import subprocess
from pathlib import Path
from pytest_cookies.plugin import Result


def test_build_image(baked_project: Result):
    working_dir = baked_project.project_path
    assert working_dir is not None
    os.chdir(str(working_dir))

    # Build baked image and run it)
    subprocess.run(  # noqa: E999
                ["/bin/bash", "-c", "make build"],
                shell=False,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                check=True,
                cwd=working_dir,
            )
    subprocess.run(  # noqa: E999
                ["/bin/bash", "-c", "make run-local"],
                shell=False,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                check=True,
                cwd=working_dir,
            )