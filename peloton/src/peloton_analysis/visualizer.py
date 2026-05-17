"""Chart generation for Peloton bike analysis."""

from __future__ import annotations

from pathlib import Path

import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

from peloton_analysis.analyzer import (
    BIKE_A_LABEL,
    BIKE_B_LABEL,
    normalize_output,
    split_by_bike,
)

matplotlib.use("Agg")

BIKE_COLORS = {
    BIKE_A_LABEL: "#E74C3C",
    BIKE_B_LABEL: "#3498DB",
}

DEFAULT_REPORTS_DIR = Path(__file__).parent.parent.parent / "reports"


def generate_all_charts(df: pd.DataFrame, output_dir: Path | None = None) -> Path:
    """Generate all analysis charts and save to output directory.

    Args:
        df: Full workout DataFrame with bike classification.
        output_dir: Directory to save charts. Defaults to peloton/reports/.

    Returns:
        Path to the output directory.
    """
    output_dir = output_dir or DEFAULT_REPORTS_DIR
    output_dir.mkdir(parents=True, exist_ok=True)

    if df.empty or "bike" not in df.columns:
        print("No classified workouts to chart.")
        return output_dir

    known = df[df["bike"].isin([BIKE_A_LABEL, BIKE_B_LABEL])]
    if known.empty:
        print("No classified workouts to chart.")
        return output_dir

    _plot_output_over_time(known, output_dir)
    _plot_normalized_trend(known, output_dir)
    _plot_resistance_distribution(df, output_dir)
    _plot_monthly_averages(known, output_dir)

    return output_dir


def _plot_output_over_time(df: pd.DataFrame, output_dir: Path) -> None:
    """Scatter plot of output over time, color-coded by bike, with trend lines."""
    fig, ax = plt.subplots(figsize=(12, 6))

    bikes = split_by_bike(df)
    for label, subset in bikes.items():
        color = BIKE_COLORS.get(label, "gray")
        ax.scatter(subset["date"], subset["total_output"], c=color, alpha=0.5, s=30, label=label)

        if len(subset) >= 2:
            days = (subset["date"] - subset["date"].iloc[0]).dt.days.values.astype(float)
            coeffs = np.polyfit(days, subset["total_output"].values, 1)
            trend_y = np.polyval(coeffs, days)
            ax.plot(subset["date"], trend_y, color=color, linewidth=2, linestyle="--")

    ax.set_xlabel("Date")
    ax.set_ylabel("Total Output (kJ)")
    ax.set_title("Output Over Time by Bike")
    ax.legend()
    fig.autofmt_xdate()
    fig.tight_layout()
    fig.savefig(output_dir / "output_over_time.png", dpi=150)
    plt.close(fig)


def _plot_normalized_trend(df: pd.DataFrame, output_dir: Path) -> None:
    """Combined normalized output trend for both bikes."""
    normalized = normalize_output(df)

    fig, ax = plt.subplots(figsize=(12, 6))

    bikes = split_by_bike(normalized)
    for label, subset in bikes.items():
        color = BIKE_COLORS.get(label, "gray")
        ax.scatter(
            subset["date"],
            subset["normalized_output"],
            c=color,
            alpha=0.4,
            s=25,
            label=label,
        )

    # Overall trend line
    if len(normalized) >= 2:
        days = (normalized["date"] - normalized["date"].iloc[0]).dt.days.values.astype(float)
        coeffs = np.polyfit(days, normalized["normalized_output"].values, 1)
        trend_y = np.polyval(coeffs, days)
        ax.plot(normalized["date"], trend_y, color="black", linewidth=2.5, label="Overall trend")

    ax.axhline(y=0, color="gray", linestyle=":", alpha=0.5)
    ax.set_xlabel("Date")
    ax.set_ylabel("Normalized Output (z-score)")
    ax.set_title("Combined Normalized Output Trend (Both Bikes)")
    ax.legend()
    fig.autofmt_xdate()
    fig.tight_layout()
    fig.savefig(output_dir / "normalized_trend.png", dpi=150)
    plt.close(fig)


def _plot_resistance_distribution(df: pd.DataFrame, output_dir: Path) -> None:
    """Histogram of average resistance to validate bike classification."""
    fig, ax = plt.subplots(figsize=(10, 5))

    ax.hist(df["avg_resistance"], bins=30, color="#2ECC71", edgecolor="black", alpha=0.7)

    ax.axvspan(70, 72, alpha=0.2, color="red", label="Bike A range (70-72)")
    ax.axvspan(74, 77, alpha=0.2, color="blue", label="Bike B range (74-77)")

    ax.set_xlabel("Average Resistance (%)")
    ax.set_ylabel("Number of Workouts")
    ax.set_title("Resistance Distribution (Bike Identification Validation)")
    ax.legend()
    fig.tight_layout()
    fig.savefig(output_dir / "resistance_distribution.png", dpi=150)
    plt.close(fig)


def _plot_monthly_averages(df: pd.DataFrame, output_dir: Path) -> None:
    """Bar chart of monthly average output per bike."""
    df = df.copy()
    df["month"] = df["date"].dt.to_period("M")

    monthly = df.groupby(["month", "bike"])["total_output"].mean().reset_index()

    fig, ax = plt.subplots(figsize=(14, 6))

    months = sorted(monthly["month"].unique())
    x = np.arange(len(months))
    width = 0.35

    for i, label in enumerate([BIKE_A_LABEL, BIKE_B_LABEL]):
        bike_data = monthly[monthly["bike"] == label]
        values = []
        for m in months:
            match = bike_data[bike_data["month"] == m]
            values.append(match["total_output"].values[0] if len(match) > 0 else 0)
        color = BIKE_COLORS.get(label, "gray")
        offset = -width / 2 + i * width
        bars = ax.bar(x + offset, values, width, label=label, color=color, alpha=0.8)
        for bar, val in zip(bars, values):
            if val > 0:
                ax.text(
                    bar.get_x() + bar.get_width() / 2,
                    bar.get_height() + 2,
                    f"{val:.0f}",
                    ha="center",
                    va="bottom",
                    fontsize=7,
                )

    ax.set_xlabel("Month")
    ax.set_ylabel("Average Output (kJ)")
    ax.set_title("Monthly Average Output by Bike")
    ax.set_xticks(x)
    ax.set_xticklabels([str(m) for m in months], rotation=45, ha="right")
    ax.legend()
    fig.tight_layout()
    fig.savefig(output_dir / "monthly_averages.png", dpi=150)
    plt.close(fig)
