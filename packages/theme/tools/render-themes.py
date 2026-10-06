#!/usr/bin/env python3

"""Renders every package's templates once per theme scheme.

A package with templates/config.toml lists its templates, one section per file
templates/<name>.mustache, each with the path its output is written to
(relative to the package directory):

    [tmtheme]
    output = "link/.config/bat/themes/{{slug}}.tmTheme"

A template is plain text with {{key}} placeholders, replaced by the value of
that key in the scheme (packages/theme/schemes/<slug>.toml). A key is a section
and a name, like {{ui.accent}}; the top-level keys are {{name}}, {{variant}}
and {{url}}, and {{slug}} is the scheme's file name. Colors are "#rrggbb"; the
filter {{ui.accent|nohash}} drops the "#", and {{description|shell}} escapes single
quotes for a value inside '...' in a shell file. A key that doesn't exist is an
error, so a typo can't ship an empty color.

Schemes and configs use a small subset of TOML: [section] headers and
`key = "string"` lines, where a key is bare or quoted ("comment.line").

REQUIRES: python3 (standard library only)

USAGE: render-themes.py <schemes-dir> <package-dir>...
"""

import re
import sys
from pathlib import Path

LINE = re.compile(r'^\s*(?:([A-Za-z0-9_-]+)|"([^"]+)")\s*=\s*"((?:[^"\\]|\\.)*)"\s*(?:#.*)?$')
SECTION = re.compile(r"^\s*\[([A-Za-z0-9_.-]+)\]\s*(?:#.*)?$")
COLOR = re.compile(r"#[0-9a-f]{6}")
COLOR_SECTIONS = ("ansi.", "ui.", "syntax.")
PLACEHOLDER = re.compile(r"\{\{\{?\s*([A-Za-z0-9_.-]+)(?:\|([a-z]+))?\s*\}?\}\}")


def parse(path):
    """Returns {"section.key": value}; top-level keys have no section."""
    values = {}
    section = ""
    for number, line in enumerate(path.read_text().splitlines(), 1):
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        match = SECTION.match(line)
        if match:
            section = match.group(1)
            continue
        match = LINE.match(line)
        if not match:
            sys.exit(f"{path}:{number}: not a section or a key = \"string\" line: {line}")
        key = match.group(1) or match.group(2)
        value = match.group(3).replace('\\"', '"').replace("\\\\", "\\")
        full = f"{section}.{key}" if section else key
        if full.startswith(COLOR_SECTIONS) and not COLOR.fullmatch(value):
            sys.exit(f"{path}:{number}: {full} is not a #rrggbb color: {value}")
        values[full] = value
    return values


def render(text, values, where):
    def replace(match):
        key, filter_ = match.group(1), match.group(2)
        if key not in values:
            line = text.count("\n", 0, match.start()) + 1
            sys.exit(f"{where}:{line}: no value for {{{{{key}}}}}")
        value = values[key]
        if filter_ == "nohash":
            return value.lstrip("#")
        if filter_ == "shell":
            return value.replace("'", "'\\''")
        if filter_:
            sys.exit(f"{where}: unknown filter '{filter_}'")
        return value

    return PLACEHOLDER.sub(replace, text)


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    schemes_dir = Path(sys.argv[1])
    schemes = sorted(schemes_dir.glob("*.toml"))
    if not schemes:
        sys.exit(f"No schemes in {schemes_dir}")
    for package in map(Path, sys.argv[2:]):
        config = package / "templates" / "config.toml"
        outputs = {}
        for key, value in parse(config).items():
            name, _, field = key.partition(".")
            if field == "output":
                outputs[name] = value
        for name, output in outputs.items():
            template = package / "templates" / f"{name}.mustache"
            text = template.read_text()
            for scheme in schemes:
                values = parse(scheme)
                values["slug"] = scheme.stem
                target = package / render(output, values, config)
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_text(render(text, values, f"{template.name} ({scheme.stem})"))


main()
