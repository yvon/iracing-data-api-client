async function plotlyData(url) {
  const response = await fetch(url);
  const csvData = await response.text();

  const points = d3.csvParseRows(csvData, d => ({
    irating: +d[0],
    lap_time: +d[1],
    start_time: d[2],
    display_name: d[3],
    car_name: d[4]
  }));

  const xValues = points.map(data => data.irating);
  const yValues = points.map(data => new Date(data.lap_time / 10));
  const timestamps = points.map(data => new Date(data.start_time).getTime());
  const hoverTexts = points.map(data => `${data.display_name}<br>${data.car_name}<br>${new Date(data.start_time).toString()}`);

  // Find the minimum and maximum timestamps.
  const minTimestamp = Math.min(...timestamps);
  const maxTimestamp = Math.max(...timestamps);

  return {
    x: xValues,
    y: yValues,
    mode: 'markers',
    type: 'scatter',
    marker: {
      color: timestamps,
      cmin: minTimestamp,
      cmax: maxTimestamp,
    },
    hovertext: hoverTexts,
  };
}

async function createPlot(container) {
  const loadingText = container.querySelector(".loading-text");

  try {
    const title = `<b>${container.dataset.title}</b>`
    const url = container.dataset.url;
    const data = await plotlyData(url);

    if (data.x.length == 0) {
      loadingText.textContent = "No data yet";
      return;
    }

    data.name = 'Races';

    const layout = {
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
      showlegend: false,
      title: title,
      hovermode: 'closest',
      xaxis: {
        title: "iRating",
      },
      yaxis: {
        title: {
          text:'Best lap time',
          standoff: 20,
        },
        tickformat: '%M:%S.%2f'
      },
    };

    Plotly.newPlot(container, [data], layout, {responsive: true});
    loadingText.classList.add("hidden");

  } catch (e) {
    console.log(e);
    loadingText.textContent = "Unexpected error";
  }

  // Load qualification data in the background
  const url = container.dataset.qualificationsUrl;
  const data = await plotlyData(url);

  data.name = 'Qualifications';
  data.visible = 'legendonly'; // Hide initially
  data.marker.colorscale = 'Viridis';

  // Add the qualification data to the plot
  Plotly.addTraces(container, data);
}

const containers = document.querySelectorAll('.plot-container');

containers.forEach(container => {
  createPlot(container);
});
