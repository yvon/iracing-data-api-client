function createHoverText(data) {
  const { displayName, carName, startTime } = data;
  return `${displayName}<br>${carName}<br>${new Date(startTime).toString()}`;
}

function createPlotlyLayout(title) {
  return {
    title: `<b>${title}</b>`,
    showlegend: false,
    hovermode: 'closest',

    margin: {
      l: 55,
      r: 10,
    },

    xaxis: {
      title: "iRating",
    },

    yaxis: {
      tickformat: '%M:%S.%3f'
    },

    updatemenus: [
      {
        buttons: [
          {
            args: [{'visible': [true, false, false]}],
            label: 'Best laps',
            method: 'update'
          },
          {
            args: [{'visible': [false, true, false]}],
            label: 'Average laps',
            method: 'update'
          },
          {
            args: [{'visible': [false, false, true]}],
            label: 'Qualifications',
            method: 'update'
          },
        ],
        showactive: true,
        type: 'buttons',
        direction: 'down',
        xanchor: 'right',
        yanchor: 'top',
        x: 1,
        y: 1
      }
    ],
  };
}

function parseCSVData(csvData) {
  return d3.csvParseRows(csvData, d => ({
    irating: +d[0],
    bestLapTime: new Date(+d[1] / 10),
    startTime: new Date(d[2]).getTime(),
    displayName: d[3],
    carName: d[4],
    averageLapTime: new Date(+d[5] / 10),
  }));
}

async function getDataPoints(url) {
  const response = await fetch(url);
  const csvData = await response.text();
  return parseCSVData(csvData);
}

async function buildTrace(points, colorscale, lapTimeAttr, visible = true) {
  const xValues = [], yValues = [], timestamps = [], hoverTexts = [];
  let minTimestamp = Infinity, maxTimestamp = -Infinity;

  for (const point of points) {
    const { irating, startTime } = point;

    xValues.push(irating);
    yValues.push(point[lapTimeAttr]);
    timestamps.push(startTime);
    hoverTexts.push(createHoverText(point));

    if (startTime < minTimestamp) {
      minTimestamp = startTime;
    }

    if (startTime > maxTimestamp) {
      maxTimestamp = startTime;
    }
  }

  return {
    x: xValues,
    y: yValues,
    mode: 'markers',
    type: 'scatter',
    visible: visible ? true : 'legendonly',
    marker: {
      color: timestamps,
      cmin: minTimestamp,
      cmax: maxTimestamp,
      colorscale: colorscale,
    },
    hovertext: hoverTexts,
  };
}

async function handleError(container, callback) {
  const loadingText = container.querySelector(".loading-text");

  try {
    await callback();
    loadingText.classList.add("hidden");
  } catch (e) {
    console.log(e);
    loadingText.textContent = "Unexpected error";
  }
}

const bestLapsScale = [
  [0, '#a39796'],
  [1, '#a61100'],
];

const averageLapsScale = [
  [0, '#8ca8ad'],
  [1, '#046580'],
];

const qualificationsScale = [
  [0, '#a39796'],
  [1, '#004040'],
];

const plotConfig = {
  responsive: true,
  displayModeBar: false
};

async function createPlot(container) {
  handleError(container, async () => {
    const title = container.dataset.title;
    const layout = createPlotlyLayout(title);

    const [raceData, qualificationData]  = await Promise.all([
      getDataPoints(container.dataset.url),
      getDataPoints(container.dataset.qualificationsUrl)
    ]);

    const traces = [
      await buildTrace(raceData, bestLapsScale, 'bestLapTime'),
      await buildTrace(raceData, averageLapsScale, 'averageLapTime', false),
      await buildTrace(qualificationData, qualificationsScale, 'bestLapTime', false),
    ];

    Plotly.newPlot(container, traces, layout, plotConfig);
  });
}

document.querySelectorAll('.plot-container').forEach(container => {
  createPlot(container);
});
