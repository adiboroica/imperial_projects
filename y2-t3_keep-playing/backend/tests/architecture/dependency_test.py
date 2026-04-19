import subprocess
from pathlib import Path

import pytest


def test_import_linter_contracts():
    """Run import-linter to verify all dependency contracts pass."""
    config = Path(__file__).parent / '.importlinter'
    result = subprocess.run(
        ['lint-imports', '--config', str(config)],
        capture_output=True,
        text=True,
    )
    assert result.returncode == 0, (
        f"import-linter found violations:\n{result.stdout}\n{result.stderr}"
    )
