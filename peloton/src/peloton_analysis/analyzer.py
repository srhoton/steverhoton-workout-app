"""Core analysis: bike classification, trend calculation, and summary."""

from __future__ import annotations

from typing import Any

import numpy as np
import pandas as pd

BIKE_A_RANGE = (70, 72)  # Harder bike
BIKE_B_RANGE = (74, 77)  # Easier bike

BIKE_A_LABEL = "Bike A (harder, 70-72 resistance)"
BIKE_B_LABEL = "Bike B (easier, 74-77 resistance)"
UNKNOWN_LABEL = "Unknown"


def classify_bike(avg_resistance: float) -> str:
    """Classify which bike was used based on average resistance.

    Args:
        avg_resistance: The workout's average resistance percentage.

    Returns:
        Bike label string.
    """
    if BIKE_A_RANGE[0] <= avg_resistance <= BIKE_A_RANGE[1]:
        return BIKE_A_LABEL
    if BIKE_B_RANGE[0] <= avg_resistance <= BIKE_B_RANGE[1]:
        return BIKE_B_LABEL
    return UNKNOWN_LABEL


def build_dataframe(workouts: list[dict[str, Any]]) -> pd.DataFrame:
    """Convert workout list to a DataFrame with bike classification.

    Args:
        workouts: List of workout dicts from client.fetch_workouts().

    Returns:
        DataFrame sorted by date with a 'bike' column added.
    """
    df = pd.DataFrame(workouts)
    if df.empty:
        return df
    df["date"] = pd.to_datetime(df["date"])
    df["bike"] = df["avg_resistance"].apply(classify_bike)
    df = df.sort_values("date").reset_index(drop=True)
    return df


def split_by_bike(df: pd.DataFrame) -> dict[str, pd.DataFrame]:
    """Split DataFrame into per-bike subsets.

    Args:
        df: Full workout DataFrame with 'bike' column.

    Returns:
        Dict mapping bike label to its subset DataFrame.
    """
    result: dict[str, pd.DataFrame] = {}
    for label in [BIKE_A_LABEL, BIKE_B_LABEL]:
        subset = df[df["bike"] == label]
        if not subset.empty:
            result[label] = subset.reset_index(drop=True)
    return result


def calculate_trend(df: pd.DataFrame) -> dict[str, float]:
    """Calculate linear trend of total_output over time.

    Args:
        df: DataFrame with 'date' and 'total_output' columns.

    Returns:
        Dict with 'slope_per_month' (kJ/month), 'r_squared', 'pct_change'.
    """
    if len(df) < 2:
        return {"slope_per_month": 0.0, "r_squared": 0.0, "pct_change": 0.0}

    days = (df["date"] - df["date"].iloc[0]).dt.days.values.astype(float)
    output = df["total_output"].values.astype(float)

    coeffs = np.polyfit(days, output, 1)
    slope_per_day = coeffs[0]
    slope_per_month = slope_per_day * 30.0

    predicted = np.polyval(coeffs, days)
    ss_res = np.sum((output - predicted) ** 2)
    ss_tot = np.sum((output - np.mean(output)) ** 2)
    r_squared = 1 - (ss_res / ss_tot) if ss_tot > 0 else 0.0

    first_pred = np.polyval(coeffs, days[0])
    last_pred = np.polyval(coeffs, days[-1])
    pct_change = ((last_pred - first_pred) / first_pred * 100) if first_pred > 0 else 0.0

    return {
        "slope_per_month": round(slope_per_month, 2),
        "r_squared": round(r_squared, 4),
        "pct_change": round(pct_change, 1),
    }


def normalize_output(df: pd.DataFrame) -> pd.DataFrame:
    """Z-score normalize total_output within each bike group.

    This allows comparing trends across bikes on the same scale.

    Args:
        df: Full DataFrame with 'bike' and 'total_output' columns.

    Returns:
        DataFrame with added 'normalized_output' column.
    """
    df = df.copy()
    df["normalized_output"] = 0.0
    for bike_label in df["bike"].unique():
        mask = df["bike"] == bike_label
        subset = df.loc[mask, "total_output"]
        mean = subset.mean()
        std = subset.std()
        if std > 0:
            df.loc[mask, "normalized_output"] = (subset - mean) / std
        else:
            df.loc[mask, "normalized_output"] = 0.0
    return df


def generate_summary(df: pd.DataFrame) -> str:
    """Generate a text summary of the analysis.

    Args:
        df: Full DataFrame with bike classification.

    Returns:
        Multi-line summary string.
    """
    lines: list[str] = []
    lines.append("=" * 60)
    lines.append("PELOTON BIKE ANALYSIS SUMMARY")
    lines.append("=" * 60)

    total = len(df)
    known = df[df["bike"] != UNKNOWN_LABEL]
    unknown_count = total - len(known)
    lines.append(f"\nTotal cycling workouts: {total}")
    lines.append(f"Classified workouts:   {len(known)}")
    if unknown_count > 0:
        lines.append(f"Unclassified (outside resistance ranges): {unknown_count}")

    bikes = split_by_bike(df)
    for label, subset in bikes.items():
        lines.append(f"\n--- {label} ---")
        lines.append(f"  Workouts:          {len(subset)}")
        lines.append(f"  Avg output (kJ):   {subset['total_output'].mean():.1f}")
        lines.append(f"  Avg resistance:    {subset['avg_resistance'].mean():.1f}")
        lines.append(f"  Avg watts:         {subset['avg_watts'].mean():.1f}")

        trend = calculate_trend(subset)
        direction = "increasing" if trend["slope_per_month"] > 0 else "decreasing"
        lines.append(
            f"  Output trend:      {direction} at {abs(trend['slope_per_month']):.1f} kJ/month"
        )
        lines.append(f"  Total change:      {trend['pct_change']:+.1f}%")
        lines.append(f"  R²:                {trend['r_squared']:.4f}")

    # Overall trend on normalized data
    if len(known) >= 2:
        normalized = normalize_output(known)
        trend_df = normalized[["date", "normalized_output"]].copy()
        trend_df = trend_df.rename(columns={"normalized_output": "total_output"})
        overall_trend = calculate_trend(trend_df)
        lines.append("\n--- OVERALL (normalized across both bikes) ---")
        direction = "IMPROVING" if overall_trend["slope_per_month"] > 0 else "DECLINING"
        lines.append(f"  Overall trend:     {direction}")
        lines.append(f"  R²:                {overall_trend['r_squared']:.4f}")

    lines.append("\n" + "=" * 60)
    return "\n".join(lines)
