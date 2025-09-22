#!/usr/bin/env python3
"""
Generate reference values for Tukey's studentized range distribution using R's ptukey.

Requires: Rscript (with base stats package available).

Usage examples:
  python3 gen_tukey_refs.py --out tukey_refs.csv
  python3 gen_tukey_refs.py --qs 2 3 4 6 --cs 3 4 5 --nranges 1 2 --dfs 5 10 20 30 --out tukey_refs.csv

This writes a CSV with columns: q,nranges,c,df,tail,log,ref
tail is one of: lower, upper; log is "true" or "false".
"""

import argparse
import csv
import os
import subprocess
import sys
import tempfile
from typing import Iterable, List, Sequence, Tuple


def _default_qs() -> List[float]:
    # Blend low and high quantiles without exploding the grid size.
    return [
        0.5,
        1.0,
        1.5,
        2.0,
        2.5,
        3.0,
        3.5,
        4.0,
        4.5,
        5.5,
        6.5,
        8.0,
        10.0,
        12.5,
        15.0,
        17.5,
        20.0,
    ]


def _default_cs() -> List[float]:
    return [float(x) for x in range(3, 31)]


def _default_nranges() -> List[float]:
    return [float(x) for x in range(1, 16)]


def _as_float_list(values: Iterable[float]) -> List[float]:
    return [float(v) for v in values]


def _build_grid(
    qs: Sequence[float],
    nranges_values: Sequence[float],
    cs: Sequence[float],
    dfs: Sequence[float],
) -> List[Tuple[float, float, float, float]]:
    grid: List[Tuple[float, float, float, float]] = []
    for q in qs:
        for nr in nranges_values:
            nranges = float(max(1, int(round(nr))))
            for c in cs:
                for df in dfs:
                    grid.append((float(q), nranges, float(c), float(df)))
    return grid


def _write_grid(path: str, grid: Sequence[Tuple[float, float, float, float]]) -> None:
    with open(path, "w", newline="") as fh:
        writer = csv.writer(fh)
        writer.writerow(["q", "nranges", "c", "df"])
        for q, nranges, c, df in grid:
            writer.writerow([f"{q:.17g}", f"{nranges:.17g}", f"{c:.17g}", f"{df:.17g}"])


def _invoke_r(input_path: str, output_path: str) -> None:
    script = """
args <- commandArgs(trailingOnly=TRUE)
input_path <- args[1]
output_path <- args[2]

frame <- read.csv(input_path, check.names=FALSE)

lower <- ptukey(frame$q, frame$c, frame$df, frame$nranges, lower.tail=TRUE, log.p=FALSE)
upper <- ptukey(frame$q, frame$c, frame$df, frame$nranges, lower.tail=FALSE, log.p=FALSE)
log_lower <- ptukey(frame$q, frame$c, frame$df, frame$nranges, lower.tail=TRUE, log.p=TRUE)
log_upper <- ptukey(frame$q, frame$c, frame$df, frame$nranges, lower.tail=FALSE, log.p=TRUE)

frame$lower <- lower
frame$upper <- upper
frame$log_lower <- log_lower
frame$log_upper <- log_upper

write.csv(frame, file=output_path, row.names=FALSE)
"""
    with tempfile.NamedTemporaryFile("w", delete=False, suffix=".R") as rfile:
        rfile.write(script)
        r_path = rfile.name
    try:
        subprocess.run([
            "Rscript",
            r_path,
            input_path,
            output_path,
        ], check=True)
    finally:
        os.unlink(r_path)


def _expand_and_write(grid_with_values_path: str, out_path: str) -> None:
    with open(grid_with_values_path, newline="") as fh_in, open(out_path, "w", newline="") as fh_out:
        reader = csv.DictReader(fh_in)
        writer = csv.writer(fh_out)
        writer.writerow(["q", "nranges", "c", "df", "tail", "log", "ref"])  # header
        for row in reader:
            q = float(row["q"])
            nranges = float(row["nranges"])
            c = float(row["c"])
            df = float(row["df"])
            lower = float(row["lower"])
            upper = float(row["upper"])
            log_lower = float(row["log_lower"])
            log_upper = float(row["log_upper"])
            for tail, is_log, value in (
                ("lower", False, lower),
                ("upper", False, upper),
                ("lower", True, log_lower),
                ("upper", True, log_upper),
            ):
                writer.writerow([
                    f"{q:.17g}",
                    f"{nranges:.17g}",
                    f"{c:.17g}",
                    f"{df:.17g}",
                    tail,
                    "true" if is_log else "false",
                    f"{value:.17g}",
                ])


def main(argv: List[str]) -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--qs", nargs="*", type=float, default=None,
                   help="List of q values to evaluate. Defaults span 0.5 through 20.0.")
    p.add_argument("--cs", nargs="*", type=float, default=None,
                   help="List of number-of-means values (c). Defaults cover 3 through 30 inclusive.")
    p.add_argument("--nranges", nargs="*", type=float, default=None,
                   help="List of nranges values. Defaults cover 1 through 15 inclusive.")
    p.add_argument("--dfs", nargs="*", type=float,
                   default=[5.0, 10.0, 20.0, 30.0, 60.0, 120.0, 240.0, 1000.0],
                   help="List of degrees of freedom values to evaluate.")
    p.add_argument("--out", required=True)
    args = p.parse_args(argv)

    qs = _as_float_list(args.qs if args.qs else _default_qs())
    cs = _as_float_list(args.cs if args.cs else _default_cs())
    nranges_values = _as_float_list(args.nranges if args.nranges else _default_nranges())
    dfs = _as_float_list(args.dfs)

    grid = _build_grid(qs, nranges_values, cs, dfs)

    with tempfile.NamedTemporaryFile("w", delete=False, suffix=".csv") as tmp_in:
        input_path = tmp_in.name
    with tempfile.NamedTemporaryFile("w", delete=False, suffix=".csv") as tmp_out:
        output_path = tmp_out.name
    try:
        _write_grid(input_path, grid)
        _invoke_r(input_path, output_path)
        _expand_and_write(output_path, args.out)
    finally:
        if os.path.exists(input_path):
            os.unlink(input_path)
        if os.path.exists(output_path):
            os.unlink(output_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
