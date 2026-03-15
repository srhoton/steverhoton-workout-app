"""CLI entry point: python -m peloton_analysis."""

from __future__ import annotations

from peloton_analysis.analyzer import build_dataframe, generate_summary
from peloton_analysis.client import fetch_workouts
from peloton_analysis.visualizer import generate_all_charts


def main() -> None:
    """Fetch Peloton data, analyze, and generate reports."""
    print("Fetching workouts from Peloton API...")
    workouts = fetch_workouts()
    print(f"Fetched {len(workouts)} cycling workouts.")

    if not workouts:
        print("No cycling workouts found.")
        return

    df = build_dataframe(workouts)

    print("\nGenerating charts...")
    output_dir = generate_all_charts(df)
    print(f"Charts saved to: {output_dir}")

    print()
    print(generate_summary(df))


if __name__ == "__main__":
    main()
