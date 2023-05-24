# iRacing Stats

iRacing Stats is a self-contained Ruby project generating the static pages of https://www.iracing-stats.com.

## About the Project

[iRacing Stats](https://www.iracing-stats.com.) provides visualizations of iRacing weekly performances.

For each active series, and for the current week, it shows graphs of lap times (Y-axis) in relation to the iRatings (X-axis).

One practical use for this could be determining a target lap time before entering a race.

## Getting started

Before running the build tasks, set the environment variables `IRACING_EMAIL` and `IRACING_PASSWORD`.

This Ruby-based project uses Rake for build tasks, which include the following:

**`rake build`**

Run rake build to fetch the week's results and generate static HTML pages and CSV content used for the graphics.

**`rake update`**

To update data if new results are available after running rake build.

## Contributions

Contributions to this project are welcomed. Feel free to create an issue or submit a Pull Request!
