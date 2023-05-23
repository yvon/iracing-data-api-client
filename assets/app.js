function createHoverText(data) {
  const { displayName, carName, startTime } = data;
  return `${displayName}<br>${carName}<br>${new Date(startTime).toString()}`;
}

function createPlotlyLayout(title) {
  return {
    title: `<b>${title}</b>`,
    showlegend: false,
    hovermode: 'closest',

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
            label: 'Best lap times',
            method: 'update'
          },
          {
            args: [{'visible': [false, true, false]}],
            label: 'Average lap times',
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
        direction: 'right',
        x: 0.5,
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

function handleError(container, callback) {
  const loadingText = container.querySelector(".loading-text");

  try {
    callback();
    loadingText.classList.add("hidden");
  } catch (e) {
    console.log(e);
    loadingText.textContent = "Unexpected error";
  }
}

async function addQualificationsTrace(container) {
  const points = await getDataPoints(container.dataset.qualificationsUrl);
  const trace = await buildTrace(points, 'Greens', 'bestLapTime', false);

  Plotly.addTraces(container, [trace]);
}

async function createPlot(container) {
  await handleError(container, async () => {
    const title = container.dataset.title;
    const layout = createPlotlyLayout(title);
    const points = await getDataPoints(container.dataset.url);

    const bestLapTimes = await buildTrace(points, 'Reds', 'bestLapTime');
    const averageLapTimes = await buildTrace(points, 'YlGnBu', 'averageLapTime', false);

    Plotly.newPlot(container, [bestLapTimes, averageLapTimes], layout, {responsive: true});
  });

  // Asynchronously loads qualification data and build trace
  addQualificationsTrace(container);
}

document.querySelectorAll('.plot-container').forEach(container => {
  createPlot(container);
});
