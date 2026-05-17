"""Tests for the visualizer module."""

from __future__ import annotations

import tempfile
from datetime import date, timedelta
from pathlib import Path

from peloton_analysis.analyzer import build_dataframe
from peloton_analysis.visualizer import generate_all_charts


def _make_mixed_workouts(count_per_bike: int = 15) -> list[dict]:
    """Generate synthetic workout data for both bikes."""
    workouts = []
    start = date(2024, 1, 1)
    for i in range(count_per_bike):
        workouts.append(
            {
                "date": start + timedelta(days=i * 4),
                "total_output": 300.0 + i * 3,
                "avg_resistance": 70.0 + (i % 3),
                "avg_cadence": 85.0,
                "avg_watts": 180.0,
                "duration_min": 30.0,
                "ride_title": f"Bike A Ride {i}",
            }
        )
        workouts.append(
            {
                "date": start + timedelta(days=i * 4 + 2),
                "total_output": 350.0 + i * 2,
                "avg_resistance": 74.0 + (i % 4),
                "avg_cadence": 88.0,
                "avg_watts": 190.0,
                "duration_min": 30.0,
                "ride_title": f"Bike B Ride {i}",
            }
        )
    return workouts


class TestGenerateAllCharts:
    def test_creates_chart_files(self) -> None:
        workouts = _make_mixed_workouts()
        df = build_dataframe(workouts)

        with tempfile.TemporaryDirectory() as tmpdir:
            output_dir = Path(tmpdir)
            generate_all_charts(df, output_dir=output_dir)

            expected_files = [
                "output_over_time.png",
                "normalized_trend.png",
                "resistance_distribution.png",
                "monthly_averages.png",
            ]
            for filename in expected_files:
                path = output_dir / filename
                assert path.exists(), f"Expected chart file {filename} not found"
                assert path.stat().st_size > 0, f"Chart file {filename} is empty"

    def test_handles_empty_data(self) -> None:
        df = build_dataframe([])
        with tempfile.TemporaryDirectory() as tmpdir:
            output_dir = Path(tmpdir)
            generate_all_charts(df, output_dir=output_dir)
