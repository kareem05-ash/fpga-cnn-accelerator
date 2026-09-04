import sys
from pathlib import Path

# Ensure the `python/` directory (parent of this conftest.py) is on sys.path
# so `model` and `generators` are importable as top-level packages, whether
# pytest is invoked from the repo root, from `python/`, or from `python/tests/`.
sys.path.insert(0, str(Path(__file__).resolve().parent))
