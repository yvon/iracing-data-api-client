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
      title: {
        text:'Best lap time',
        standoff: 20,
      },
      tickformat: '%M:%S.%3f'
    },

    updatemenus: [
      {
        buttons: [
          {
            args: [{'visible': [true, false]}],
            label: 'Races',
            method: 'update'
          },
          {
            args: [{'visible': [false, true]}],
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
    lapTime: new Date(+d[1] / 10),
    startTime: new Date(d[2]).getTime(),
    displayName: d[3],
    carName: d[4],
  }));
}

async function getDataPoints(url) {
  const response = await fetch(url);
  const csvData = await response.text();
  return parseCSVData(csvData);
}

async function buildTrace(url, name, visible = true) {
  const points = await getDataPoints(url);

  const xValues = [], yValues = [], timestamps = [], hoverTexts = [];
  let minTimestamp = Infinity, maxTimestamp = -Infinity;

  for (const point of points) {
    const hoverText = createHoverText(point);
    const { irating, lapTime, startTime } = point;

    xValues.push(irating);
    yValues.push(lapTime);
    timestamps.push(startTime);
    hoverTexts.push(hoverText);

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
    name: name,
    visible: visible ? true : 'legendonly',
    marker: {
      color: timestamps,
      cmin: minTimestamp,
      cmax: maxTimestamp,
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
  const url = container.dataset.qualificationsUrl;
  const trace = await buildTrace(url, 'Qualifications', false);

  trace.marker.colorscale = 'Viridis';
  Plotly.addTraces(container, [trace]);
}

async function createPlot(container) {
  await handleError(container, async () => {
    // Layout
    const title = container.dataset.title;
    const layout = createPlotlyLayout(title);

    // Trace
    const url = container.dataset.url;
    const trace = await buildTrace(url, 'Races');

    Plotly.newPlot(container, [trace], layout, {responsive: true});
  });

  // Asynchronously loads qualification data and build trace
  addQualificationsTrace(container);
}

document.querySelectorAll('.plot-container').forEach(container => {
  createPlot(container);
});
