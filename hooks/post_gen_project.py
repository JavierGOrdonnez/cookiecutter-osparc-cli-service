#
# When the hook scripts script are run, their current working directory is the root of the generated project
#
# SEE https://cookiecutter.readthedocs.io/en/stable/advanced/hooks.html

import shutil
import sys
from pathlib import Path
import os
from contextlib import contextmanager


SELECTED_GIT_REPO = "{{ cookiecutter.git_repo }}"



def create_ignore_listings():
    # .gitignore
    common_gitignore = Path("Common.gitignore")
    python_gitignore = Path("Python.gitignore")

    gitignore_file = Path(".gitignore")
    gitignore_file.unlink(missing_ok=True)
    shutil.copyfile(common_gitignore, gitignore_file)

    with gitignore_file.open("at") as fh:
        fh.write("\n")
        fh.write(python_gitignore.read_text())

    common_gitignore.unlink()
    python_gitignore.unlink()

    # .dockerignore
    common_dockerignore = Path("Common.dockerignore")
    dockerignore_file = Path(".dockerignore")
    dockerignore_file.unlink(missing_ok=True)
    shutil.copyfile(common_dockerignore, dockerignore_file)

    # appends .gitignore above
    with dockerignore_file.open("at") as fh:
        fh.write("\n")
        fh.write(gitignore_file.read_text())

    common_dockerignore.unlink()


def create_repo_folder():
    if SELECTED_GIT_REPO != "github":
        shutil.rmtree(".github")
    if SELECTED_GIT_REPO != "gitlab":
        shutil.rmtree(".gitlab")


@contextmanager
def context_print(
    msg,
):
    print("-", msg, end="...", flush=True)
    yield
    print("DONE")


def main():
    print("Starting post-gen-project hook:", flush=True)
    try:
        with context_print("Updating .gitignore and .dockerignore configs"):
            create_ignore_listings()

        with context_print("Adding config for selected external repository"):
            create_repo_folder()

    except Exception as exc:  # pylint: disable=broad-except
        print("ERROR", exc)
        return os.EX_SOFTWARE
    return os.EX_OK


if __name__ == "__main__":
    sys.exit(main())
