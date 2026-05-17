"""Tests for the analyzer module."""

from __future__ import annotations

from datetime import date, timedelta

from peloton_analysis.analyzer import (
    BIKE_A_LABEL,
    BIKE_B_LABEL,
    UNKNOWN_LABEL,
    build_dataframe,
    calculate_trend,
    classify_bike,
    generate_summary,
    normalize_output,
    split_by_bike,
)


def _make_workouts(
    count: int = 20,
    start_date: date | None = None,
    resistance_range: tuple[float, float] = (70.0, 72.0),
    base_output: float = 300.0,
    output_growth: float = 2.0,
) -> list[dict]:
    """Generate synthetic workout data for testing."""
    start = start_date or date(2024, 1, 1)
    workouts = []
    for i in range(count):
        r_low, r_high = resistance_range
        resistance = r_low + (r_high - r_low) * (i % 3) / 2
        workouts.append(
            {
                "date": start + timedelta(days=i * 3),
                "total_output": base_output + i * output_growth,
                "avg_resistance": resistance,
                "avg_cadence": 85.0,
                "avg_watts": 180.0 + i,
                "duration_min": 30.0,
                "ride_title": f"Ride {i}",
            }
        )
    return workouts


class TestClassifyBike:
    def test_bike_a_range(self) -> None:
        assert classify_bike(70.0) == BIKE_A_LABEL
        assert classify_bike(71.0) == BIKE_A_LABEL
        assert classify_bike(72.0) == BIKE_A_LABEL

    def test_bike_b_range(self) -> None:
        assert classify_bike(74.0) == BIKE_B_LABEL
        assert classify_bike(75.5) == BIKE_B_LABEL
        assert classify_bike(77.0) == BIKE_B_LABEL

    def test_unknown_range(self) -> None:
        assert classify_bike(50.0) == UNKNOWN_LABEL
        assert classify_bike(73.0) == UNKNOWN_LABEL
        assert classify_bike(78.0) == UNKNOWN_LABEL
        assert classify_bike(69.9) == UNKNOWN_LABEL

    def test_boundary_values(self) -> None:
        assert classify_bike(70.0) == BIKE_A_LABEL
        assert classify_bike(72.0) == BIKE_A_LABEL
        assert classify_bike(74.0) == BIKE_B_LABEL
        assert classify_bike(77.0) == BIKE_B_LABEL


class TestBuildDataframe:
    def test_builds_with_bike_column(self) -> None:
        workouts = _make_workouts(count=5)
        df = build_dataframe(workouts)
        assert "bike" in df.columns
        assert len(df) == 5

    def test_sorted_by_date(self) -> None:
        workouts = _make_workouts(count=10)
        df = build_dataframe(workouts)
        dates = df["date"].tolist()
        assert dates == sorted(dates)

    def test_empty_input(self) -> None:
        df = build_dataframe([])
        assert df.empty


class TestSplitByBike:
    def test_splits_correctly(self) -> None:
        bike_a = _make_workouts(count=5, resistance_range=(70.0, 72.0))
        bike_b = _make_workouts(count=5, resistance_range=(74.0, 77.0))
        df = build_dataframe(bike_a + bike_b)
        splits = split_by_bike(df)
        assert BIKE_A_LABEL in splits
        assert BIKE_B_LABEL in splits
        assert len(splits[BIKE_A_LABEL]) == 5
        assert len(splits[BIKE_B_LABEL]) == 5


class TestCalculateTrend:
    def test_increasing_trend(self) -> None:
        workouts = _make_workouts(count=20, output_growth=5.0)
        df = build_dataframe(workouts)
        trend = calculate_trend(df)
        assert trend["slope_per_month"] > 0
        assert trend["pct_change"] > 0
        assert 0 <= trend["r_squared"] <= 1

    def test_single_workout(self) -> None:
        workouts = _make_workouts(count=1)
        df = build_dataframe(workouts)
        trend = calculate_trend(df)
        assert trend["slope_per_month"] == 0.0

    def test_flat_trend(self) -> None:
        workouts = _make_workouts(count=10, output_growth=0.0)
        df = build_dataframe(workouts)
        trend = calculate_trend(df)
        assert abs(trend["slope_per_month"]) < 0.01


class TestNormalizeOutput:
    def test_produces_normalized_column(self) -> None:
        bike_a = _make_workouts(count=10, resistance_range=(70.0, 72.0), base_output=300)
        bike_b = _make_workouts(count=10, resistance_range=(74.0, 77.0), base_output=400)
        df = build_dataframe(bike_a + bike_b)
        normalized = normalize_output(df)
        assert "normalized_output" in normalized.columns

    def test_zero_mean_per_bike(self) -> None:
        bike_a = _make_workouts(count=10, resistance_range=(70.0, 72.0))
        bike_b = _make_workouts(count=10, resistance_range=(74.0, 77.0))
        df = build_dataframe(bike_a + bike_b)
        normalized = normalize_output(df)
        for label in [BIKE_A_LABEL, BIKE_B_LABEL]:
            subset = normalized[normalized["bike"] == label]
            assert abs(subset["normalized_output"].mean()) < 1e-10


class TestGenerateSummary:
    def test_produces_output(self) -> None:
        workouts = _make_workouts(count=10)
        df = build_dataframe(workouts)
        summary = generate_summary(df)
        assert "PELOTON BIKE ANALYSIS SUMMARY" in summary
        assert "Total cycling workouts: 10" in summary
