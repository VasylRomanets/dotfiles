#!/usr/bin/env python3

"""Converts a bat (TextMate) .tmTheme plus a Ghostty theme into a Tinted8 scheme.

The scheme is printed to stdout, ready to save as
packages/theme/schemes/<slug>.yaml. The palette and terminal colors come from
the Ghostty theme, the syntax colors from the .tmTheme: every Tinted8 syntax
key gets the color the .tmTheme gives a token with that exact scope.

REQUIRES: python3 (standard library only)

USAGE: tmtheme-to-scheme.py <slug> <theme.tmTheme> <ghostty-theme-file>
           [--name NAME] [--credit URL] [--accent '#rrggbb']

Check the result by hand: the values are an extraction, and Tinted8 has fewer
keys than a rich .tmTheme has scopes.
"""

import argparse
import colorsys
import re
import sys
import xml.etree.ElementTree as ET

# The syntax keys tinted-builder 0.21.0 accepts (Tinted8 styling 0.2.0), with
# parents listed before their children.
SYNTAX_KEYS = [
    "comment", "comment.line", "comment.block", "comment.documentation",
    "invalid", "invalid.deprecated", "invalid.illegal", "string",
    "string.quoted", "string.quoted.single", "string.quoted.double",
    "string.regexp", "string.template", "string.interpolated",
    "string.unquoted", "string.other", "constant", "constant.numeric",
    "constant.numeric.integer", "constant.numeric.float",
    "constant.numeric.hex", "constant.language", "constant.character",
    "constant.character.escape", "constant.character.entity",
    "constant.other", "entity", "entity.name", "entity.name.class",
    "entity.name.function", "entity.name.function.constructor",
    "entity.name.label", "entity.name.tag", "entity.name.type",
    "entity.name.type.class", "entity.name.type.enum",
    "entity.name.type.struct", "entity.name.namespace",
    "entity.name.section", "entity.other", "entity.other.attribute-name",
    "entity.other.inherited-class", "keyword", "keyword.control",
    "keyword.control.import", "keyword.control.flow", "keyword.declaration",
    "keyword.operator", "keyword.other", "storage", "storage.type",
    "storage.modifier", "support", "support.function",
    "support.function.builtin", "support.class", "support.type",
    "support.constant", "support.variable", "support.other", "variable",
    "variable.parameter", "variable.language", "variable.other",
    "variable.other.constant", "variable.other.property",
    "variable.other.object", "punctuation", "punctuation.separator",
    "punctuation.definition", "punctuation.definition.string",
    "punctuation.definition.comment", "punctuation.section",
    "punctuation.brackets", "punctuation.brackets.angle",
    "punctuation.brackets.curly", "punctuation.brackets.round",
    "punctuation.brackets.square", "markup", "markup.bold", "markup.italic",
    "markup.quote", "markup.underline", "markup.heading", "markup.list",
    "markup.list.numbered", "markup.list.unnumbered", "markup.link",
    "markup.raw", "markup.inserted", "markup.changed", "markup.deleted",
    "source", "text", "meta", "meta.function", "meta.class", "meta.block",
    "meta.tag", "meta.type", "meta.import", "meta.preprocessor",
    "meta.embedded", "meta.object", "meta.annotation",
]

# Delimiters sit inside the scope they delimit, so without a rule of their own
# they take that scope's color (TextMate semantics). Tinted8's inheritance only
# follows a key's own prefix, so this has to be spelled out in the scheme.
CONTAINERS = {
    "punctuation.definition.string": "string",
    "punctuation.definition.comment": "comment",
}


# --- Colors -------------------------------------------------------------------


def parse_color(value, over=None):
    """Parses #RGB, #RGBA, #RRGGBB or #RRGGBBAA, blending alpha over `over`."""
    if not value:
        return None
    digits = value.strip().lstrip("#")
    if not re.fullmatch(r"[0-9a-fA-F]+", digits):
        return None
    if len(digits) in (3, 4):
        digits = "".join(c * 2 for c in digits)
    if len(digits) not in (6, 8):
        return None
    r, g, b = (int(digits[i : i + 2], 16) for i in (0, 2, 4))
    alpha = int(digits[6:8], 16) / 255 if len(digits) == 8 else 1.0
    if alpha < 1.0 and over:
        base = rgb(over)
        r, g, b = (round(c * alpha + o * (1 - alpha)) for c, o in zip((r, g, b), base))
    return "#%02x%02x%02x" % (r, g, b)


def rgb(color):
    digits = color.lstrip("#")
    return tuple(int(digits[i : i + 2], 16) for i in (0, 2, 4))


def blend(base, toward, amount):
    """Returns `base` moved `amount` (0-1) of the way toward `toward`."""
    a, b = rgb(base), rgb(toward)
    return "#%02x%02x%02x" % tuple(round(a[i] * (1 - amount) + b[i] * amount) for i in range(3))


def luminance(color):
    r, g, b = rgb(color)
    return (0.299 * r + 0.587 * g + 0.114 * b) / 255


def hue_saturation(color):
    r, g, b = (c / 255 for c in rgb(color))
    hue, _, saturation = colorsys.rgb_to_hls(r, g, b)
    return hue * 360, saturation


# --- tmTheme ------------------------------------------------------------------


def plist_value(element):
    if element.tag == "dict":
        kids = list(element)
        return {kids[i].text: plist_value(kids[i + 1]) for i in range(0, len(kids), 2)}
    if element.tag == "array":
        return [plist_value(kid) for kid in element]
    if element.tag == "string":
        return element.text or ""
    return None


def load_tmtheme(path):
    """Returns (global settings, [(scope atoms, settings)]) from a .tmTheme.

    Parsed leniently: some upstream files have comments before the XML
    declaration, or none at all.
    """
    with open(path, encoding="utf-8", errors="replace") as handle:
        text = handle.read()
    root = ET.fromstring(text[text.index("<plist") :])
    global_settings, rules = {}, []
    for entry in plist_value(root[0])["settings"]:
        settings = entry.get("settings", {})
        if "scope" not in entry:
            global_settings.update(settings)
            continue
        # Selectors with whitespace are descendant selectors or exclusions,
        # which are specific to one language; only plain scopes are used.
        atoms = [s.strip() for s in entry["scope"].split(",")]
        atoms = [a for a in atoms if a and not re.search(r"\s", a)]
        if atoms:
            rules.append((atoms, settings))
    return global_settings, rules


def scope_color(key, rules, background):
    """The color the theme gives a token scoped exactly `key`, or None."""
    best = None
    for index, (atoms, settings) in enumerate(rules):
        color = parse_color(settings.get("foreground"), background)
        if not color:
            continue
        for atom in atoms:
            if key == atom or key.startswith(atom + "."):
                rank = (len(atom), index)
                if best is None or rank > best[0]:
                    best = (rank, color)
    return best[1] if best else None


# --- Ghostty ------------------------------------------------------------------


def load_ghostty(path):
    palette, options = {}, {}
    with open(path, encoding="utf-8") as handle:
        for line in handle:
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, value = (part.strip() for part in line.split("=", 1))
            if key == "palette":
                index, color = value.split("=", 1)
                palette[int(index)] = color.strip().lower()
            else:
                options[key] = value.lower()
    return palette, options


# --- Scheme -------------------------------------------------------------------


def convert(tmtheme_path, ghostty_path, accent=None):
    settings, rules = load_tmtheme(tmtheme_path)
    palette, options = load_ghostty(ghostty_path)

    bg = parse_color(options["background"])
    fg = parse_color(options["foreground"])
    dark = luminance(bg) < 0.5
    editor_bg = parse_color(settings.get("background"), bg) or bg
    editor_fg = parse_color(settings.get("foreground"), editor_bg) or fg

    # Only keys whose color differs from what they would inherit are written.
    syntax, resolved = {}, {}
    for key in SYNTAX_KEYS:
        value = scope_color(key, rules, editor_bg)
        if value is None and key in CONTAINERS:
            value = resolved[CONTAINERS[key]]
        if value is None:
            value = editor_fg
        resolved[key] = value
        ancestor = key.rsplit(".", 1)[0] if "." in key else None
        while ancestor and ancestor not in syntax:
            ancestor = ancestor.rsplit(".", 1)[0] if "." in ancestor else None
        if ancestor is None or syntax[ancestor] != value:
            syntax[key] = value

    comment = resolved["comment"]
    number = resolved["constant.numeric"]
    hue, saturation = hue_saturation(number)

    # The black and white palette entries are the dark and light anchors:
    # background and text in a dark scheme, swapped in a light one.
    colors = {"black": bg, "white": fg} if dark else {"black": fg, "white": bg}
    for name, index in (("red", 1), ("green", 2), ("yellow", 3), ("blue", 4), ("magenta", 5), ("cyan", 6)):
        colors[name] = palette[index]
        colors[name + "-bright"] = palette[index + 8]
    colors["gray"] = comment
    if 12 <= hue <= 48 and saturation > 0.25:
        colors["orange"] = number

    selection = (
        parse_color(settings.get("selection"), editor_bg)
        or parse_color(options.get("selection-background"))
        or blend(bg, fg, 0.15)
    )
    ui = {
        "accent.normal": accent or palette[6],
        "selection.background": selection,
        "highlight.line.background": parse_color(settings.get("lineHighlight"), editor_bg) or blend(bg, fg, 0.06),
        "cursor.normal.background": parse_color(settings.get("caret"), editor_bg)
        or parse_color(options.get("cursor-color"))
        or fg,
        "border.normal": blend(bg, fg, 0.22),
        "gutter.foreground": comment,
        "chrome.background.normal": blend(bg, fg, 0.06),
        "chrome.background.dark": blend(bg, "#000000", 0.30) if dark else blend(bg, fg, 0.10),
        "chrome.foreground.dark": blend(bg, fg, 0.65),
    }
    return dark, colors, syntax, ui


def nest(flat):
    """{'a.b': v, 'a.c': w} -> {'a': {'b': v, 'c': w}}."""
    tree = {}
    for key, value in flat.items():
        node = tree
        *parents, leaf = key.split(".")
        for part in parents:
            node = node.setdefault(part, {})
        node[leaf] = value
    return tree


def emit_tree(lines, tree, depth):
    for key, value in tree.items():
        pad = "  " * depth
        if isinstance(value, dict):
            lines.append(f"{pad}{key}:")
            emit_tree(lines, value, depth + 1)
        else:
            lines.append(f'{pad}{key}: "{value}"')


def render(slug, name, credit, tmtheme_name, ghostty_name, dark, colors, syntax, ui):
    lines = [
        f"# Converted from {tmtheme_name} and Ghostty theme {ghostty_name}.",
        "",
        "scheme:",
        '  system: "tinted8"',
        "  supports:",
        '    styling-spec: "0.2.0"',
        '  author: "Vasyl Romanets"',
    ]
    if credit:
        lines.append(f'  theme-author: "{credit}"')
    lines += [
        f'  name: "{name}"',
        f'  slug: "{slug}"',
        f'variant: "{"dark" if dark else "light"}"',
        "palette:",
    ]
    lines += [f'  {key}: "{value}"' for key, value in colors.items()]
    lines.append("syntax:")
    lines += [f'  {key}: "{value}"' for key, value in syntax.items()]
    lines.append("ui:")
    emit_tree(lines, nest(ui), 1)
    return "\n".join(lines) + "\n"


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("slug")
    parser.add_argument("tmtheme")
    parser.add_argument("ghostty")
    parser.add_argument("--name", help="display name (default: title-cased slug)")
    parser.add_argument("--credit", default="", help="URL of the original theme")
    parser.add_argument("--accent", help="accent color, e.g. '#89b4fa' (default: ANSI cyan)")
    args = parser.parse_args()

    name = args.name or " ".join(word.capitalize() for word in args.slug.split("-"))
    dark, colors, syntax, ui = convert(args.tmtheme, args.ghostty, args.accent)
    sys.stdout.write(
        render(
            args.slug, name, args.credit,
            args.tmtheme.rsplit("/", 1)[-1], args.ghostty.rsplit("/", 1)[-1],
            dark, colors, syntax, ui,
        )
    )


if __name__ == "__main__":
    main()
