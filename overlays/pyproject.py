import sys
from functools import partial
from pathlib import Path
from typing import Callable, Iterable, Tuple, Union

import tomlkit

PROJECT_KEY = "project"
DEPENDENCIES_KEY = "dependencies"
TOOL_KEY = "tool"
POETRY_KEY = "poetry"


def modify_dependency(dependency: str):
    last_index = None
    for idx, character in enumerate(dependency):
        if character in " >=":
            last_index = idx
            break

    if last_index is None:
        last_index = len(dependency)

    return dependency[0:last_index]


def modify_dependency_poetry(item: Tuple[str, Union[str, dict]]) -> Tuple[str, dict]:
    key = item[0]
    value = item[1]
    if isinstance(value, dict):
        value["version"] = "*"
        return key, value

    elif isinstance(value, str):
        return key, dict(version="*")
    else:
        raise ValueError("Expected dict or str type value.")


def filter_dependencies(dependencies: Iterable, dependencies_to_remove: tuple):
    return filter(
        lambda dependency: dependency not in dependencies_to_remove,
        dependencies,
    )


def poetry_project(
    pyproject_contents: tomlkit.TOMLDocument, dependencies_filter: Callable
) -> dict:
    dependencies = pyproject_contents[TOOL_KEY][POETRY_KEY][DEPENDENCIES_KEY]

    dependencies_modified = map(modify_dependency_poetry, dependencies.items())

    dependencies_filtered = dependencies_filter(
        dependencies=dependencies_modified,
    )
    # TODO: Works otherwise but creates separate headings for each key
    # if the value is not a dictionary. E.g.
    # [project.poetry.dependencies.dataclasses-json]
    # version = "*"
    # Does not matter for computer parsing but ugly.

    pyproject_contents[TOOL_KEY][POETRY_KEY][DEPENDENCIES_KEY] = dict(
        dependencies_filtered
    )
    # pyproject_contents = pyproject_contents.add(
    #     PROJECT_KEY, {POETRY_KEY: {DEPENDENCIES_KEY: dict(dependencies_filtered)}}
    # )

    return pyproject_contents


def plain_project(pyproject_contents: dict, dependencies_filter: Callable) -> dict:
    dependencies = pyproject_contents[PROJECT_KEY][DEPENDENCIES_KEY]

    dependencies_modified = map(
        modify_dependency,
        dependencies,
    )
    dependencies_filtered = dependencies_filter(dependencies=dependencies_modified)

    pyproject_contents[PROJECT_KEY][DEPENDENCIES_KEY] = list(dependencies_filtered)
    return pyproject_contents


def main(pyproject_path: Path, dependencies_to_remove: Tuple[str, ...] = ()):
    pyproject_contents = tomlkit.loads(pyproject_path.read_text())
    pypproject_contents_modified = pyproject_contents.copy()

    dependencies_filter = partial(
        filter_dependencies, dependencies_to_remove=dependencies_to_remove
    )

    if PROJECT_KEY in pyproject_contents:
        pypproject_contents_modified = plain_project(
            pyproject_contents=pyproject_contents,
            dependencies_filter=dependencies_filter,
        )

    elif TOOL_KEY in pyproject_contents:
        pypproject_contents_modified = poetry_project(
            pyproject_contents=pyproject_contents,
            dependencies_filter=dependencies_filter,
        )

    else:
        raise ValueError(
            f"Expected either f{PROJECT_KEY} or f{TOOL_KEY} in pyproject.toml."
        )

    pyproject_path.write_text(tomlkit.dumps(pypproject_contents_modified))


if __name__ == "__main__":
    dependencies_to_remove = ()
    if len(sys.argv) > 2:
        dependencies_to_remove = tuple(sys.argv[2:])
    main(
        pyproject_path=Path(sys.argv[1]), dependencies_to_remove=dependencies_to_remove
    )
