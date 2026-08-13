#!/usr/bin/env python3
"""Generate a Markdown comparison of legacy and vl_weaponry tool values.

The data in this file is intentionally maintained by hand. Run:

    python3 tools/generate_weaponry_comparison.py

or pass a different output path as the sole argument.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path
from typing import Callable


MATERIAL_ORDER = ("wood", "stone", "deepslate", "iron", "gold", "diamond", "netherite")
TYPE_ORDER = ("pickaxe", "shovel", "axe", "sword", "hoe", "hammer", "spear", "scythe")

COLUMNS = (
    ("durability", "Durability"),
    ("dig_speed", "Dig speed"),
    ("harvest_level", "Harvest level"),
    ("damage", "Damage"),
    ("attack_interval", "Attack interval"),
    ("enchantability", "Enchantability"),
)


@dataclass(frozen=True)
class Stats:
    durability: float
    dig_speed: float | None
    harvest_level: float
    damage: float
    attack_interval: float
    enchantability: float


# Current values come from vl_weaponry material stat_modifiers. Keeping these
# separate from tool types mirrors the Lua API and makes balance edits simple.
CURRENT_MATERIALS = {
    "wood":      dict(durability=60,   dig_speed=2,    harvest_level=1, damage=0,    interval_delta=0,    enchantability=15),
    "stone":     dict(durability=132,  dig_speed=4,    harvest_level=3, damage=1,    interval_delta=0.1,  enchantability=5),
    "deepslate": dict(durability=150,  dig_speed=4.25, harvest_level=3, damage=1.25, interval_delta=0.1,  enchantability=5),
    "iron":      dict(durability=251,  dig_speed=6,    harvest_level=4, damage=2,    interval_delta=0,    enchantability=14),
    "gold":      dict(durability=133,   dig_speed=12,   harvest_level=2, damage=0,    interval_delta=-0.2, enchantability=22),
    "diamond":   dict(durability=1562, dig_speed=8,    harvest_level=5, damage=3,    interval_delta=0,    enchantability=10),
    "netherite": dict(durability=2031, dig_speed=9.5,  harvest_level=6, damage=5,    interval_delta=0,    enchantability=10),
}


def fixed(value: float) -> Callable[[float, float], float]:
    return lambda _speed, _delta: value


def material_interval(base: float) -> Callable[[float, float], float]:
    return lambda _speed, delta: base + delta


# base_damage and interval reproduce each tool type's base_stats and
# build_definition formula. Spear has no material-dependent dig speed.
CURRENT_TYPES = {
    "pickaxe": dict(base_damage=2, max_damage=None, dig=True, interval=fixed(0.83333333)),
    "shovel":  dict(base_damage=2, max_damage=5, dig=True, interval=fixed(1)),
    "axe":     dict(base_damage=7, max_damage=10, dig=True, interval=lambda speed, _delta: max(1, 1.25 - max(speed - 4, 0) / 14)),
    "sword":   dict(base_damage=4, max_damage=None, dig=True, interval=fixed(0.625)),
    "hoe":     dict(base_damage=1, max_damage=None, dig=True, interval=lambda speed, _delta: max(2 / speed, 0.25)),
    "hammer":  dict(base_damage=4, max_damage=None, dig=True, interval=material_interval(1.2)),
    "spear":   dict(base_damage=3, max_damage=None, dig=False, interval=fixed(0.75)),
    "scythe":  dict(base_damage=5, max_damage=None, dig=True, interval=material_interval(1.1)),
}


def make_current(tool_type: str, material: str) -> Stats:
    mat = CURRENT_MATERIALS[material]
    tool = CURRENT_TYPES[tool_type]
    speed = mat["dig_speed"]
    damage = tool["base_damage"] + mat["damage"]
    if tool["max_damage"] is not None:
        damage = min(damage, tool["max_damage"])
    return Stats(
        durability=mat["durability"],
        dig_speed=speed if tool["dig"] else None,
        harvest_level=mat["harvest_level"],
        damage=damage,
        attack_interval=tool["interval"](speed, mat["interval_delta"]),
        enchantability=mat["enchantability"],
    )


# Legacy mcl_tools/mcl_farming values which were explicitly registered before
# the migration. Values not overridden here were already supplied through the
# vl_weaponry API and are therefore equal to the current value.
LEGACY_MATERIALS = {
    "wood":      (60, 2, 1, 15),
    "stone":     (132, 4, 3, 5),
    "deepslate": (150, 4.25, 3, 5),
    "iron":      (251, 6, 4, 14),
    "gold":      (33, 12, 2, 22),
    "diamond":   (1562, 8, 5, 10),
    "netherite": (2031, 9, 6, 10),
}

LEGACY_DAMAGE = {
    "pickaxe": (2, 3, 3, 4, 2, 5, 6),
    "shovel":  (2, 3, 3, 4, 2, 5, 5),
    "axe":     (7, 9, 9, 9, 7, 9, 10),
    "sword":   (4, 5, 5, 6, 4, 7, 9),
    "hoe":     (1, 1, 1, 2, 1, 3, 4),
}

LEGACY_INTERVAL = {
    "pickaxe": (0.83333333,) * 7,
    "shovel":  (1,) * 7,
    "axe":     (1.25, 1.25, 1.25, 1.11111111, 1, 1, 1),
    "sword":   (0.625,) * 7,
    "hoe":     (1, 0.5, 0.5, 0.33333333, 0.25, 0.25, 0.25),
}


def make_old(tool_type: str, material: str) -> Stats:
    current = make_current(tool_type, material)
    if tool_type not in LEGACY_DAMAGE:
        return current

    index = MATERIAL_ORDER.index(material)
    durability, speed, level, enchantability = LEGACY_MATERIALS[material]

    # These two hoes used an explicit legacy enchantability of 15.
    if tool_type == "hoe" and material in ("diamond", "netherite"):
        enchantability = 15

    # Legacy netherite sword used diamond-tier dig stats.
    if tool_type == "sword" and material == "netherite":
        speed, level = 8, 5

    return Stats(
        durability=durability,
        dig_speed=speed,
        harvest_level=level,
        damage=LEGACY_DAMAGE[tool_type][index],
        attack_interval=LEGACY_INTERVAL[tool_type][index],
        enchantability=enchantability,
    )


def format_number(value: float | None) -> str:
    if value is None:
        return "—"
    if float(value).is_integer():
        return str(int(value))
    return f"{value:.8f}".rstrip("0").rstrip(".")


def format_comparison(old: float | None, new: float | None) -> str:
    old_text = format_number(old)
    new_text = format_number(new)
    return old_text if old_text == new_text else f"{old_text} -> {new_text}"


def table(rows: list[list[str]], widths: list[int]) -> list[str]:
    def render(row: list[str]) -> str:
        return "| " + " | ".join(value.ljust(width) for value, width in zip(row, widths)) + " |"

    alignment = [":" + "-" * (width - 1) for width in widths]
    return [render(rows[0]), render(alignment), *(render(row) for row in rows[1:])]


def comparison_row(label: str, tool_type: str, material: str) -> list[str]:
    old = make_old(tool_type, material)
    new = make_current(tool_type, material)
    return [label] + [
        format_comparison(getattr(old, field), getattr(new, field))
        for field, _heading in COLUMNS
    ]


def generate_markdown() -> str:
    headings = ["Tool type"] + [heading for _field, heading in COLUMNS]
    material_tables: list[tuple[str, list[list[str]]]] = []
    type_tables: list[tuple[str, list[list[str]]]] = []

    for material in MATERIAL_ORDER:
        rows = [headings] + [comparison_row(tool_type, tool_type, material) for tool_type in TYPE_ORDER]
        material_tables.append((material, rows))

    headings = ["Material"] + [heading for _field, heading in COLUMNS]
    for tool_type in TYPE_ORDER:
        rows = [headings] + [comparison_row(material, tool_type, material) for material in MATERIAL_ORDER]
        type_tables.append((tool_type, rows))

    all_rows = [row for _name, rows in material_tables + type_tables for row in rows]
    widths = [max(len(row[column]) for row in all_rows) for column in range(len(COLUMNS) + 1)]

    lines = [
        "# Tool value comparison",
        "",
        "Unchanged fields show one value; changed fields show `old -> new`.",
        "",
        "## Grouped by material",
    ]
    for name, rows in material_tables:
        lines.extend(("", f"### {name.title()}", "", *table(rows, widths)))

    lines.extend(("", "## Grouped by tool type"))
    for name, rows in type_tables:
        lines.extend(("", f"### {name.title()}", "", *table(rows, widths)))

    return "\n".join(lines) + "\n"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "output",
        nargs="?",
        type=Path,
        default=Path(__file__).with_name("weaponry_comparison.md"),
        help="Markdown output path (default: tools/weaponry_comparison.md)",
    )
    args = parser.parse_args()
    args.output.write_text(generate_markdown(), encoding="utf-8")
    print(f"Wrote {args.output}")


if __name__ == "__main__":
    main()
