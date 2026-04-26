"""Architecture tests — invokes import-linter via subprocess so contracts run inside pytest."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path


def test_import_linter_contracts() -> None:
    """All contracts in ``tests/architecture/.importlinter`` pass."""
    config_path = Path(__file__).parent / ".importlinter"
    backend_root = Path(__file__).parent.parent.parent

    # `import-linter` ships a `lint-imports` console script — there is no
    # `__main__` so `python -m importlinter` does not work. Use `runpy` to
    # invoke the console-script entry point in the same interpreter.
    result = subprocess.run(
        [
            sys.executable,
            "-c",
            "from importlinter.cli import lint_imports_command; lint_imports_command()",
            "--config",
            str(config_path),
        ],
        cwd=backend_root,
        capture_output=True,
        text=True,
    )

    if result.returncode != 0:
        message = (
            "import-linter contract violation:\n"
            f"--- stdout ---\n{result.stdout}\n"
            f"--- stderr ---\n{result.stderr}"
        )
        raise AssertionError(message)
