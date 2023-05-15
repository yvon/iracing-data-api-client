async function createPlot(container) {
  const loadingText = container.querySelector(".loading-text");

  try {
    const url = container.dataset.url;
    const response = await fetch(url);
    const jsonData = await response.json();
    const points = jsonData.points

    if (points.length == 0) {
      loadingText.textContent = "No data yet";
      return;
    }

    const title = `<b>${container.dataset.title}</b>`
    const xValues = points.map(data => data.irating);
    const yValues = points.map(data => new Date(data.lap_time / 10));
    const timestamps = points.map(data => new Date(data.start_time).getTime());
    const hoverTexts = points.map(data => `${data.display_name}<br>${data.car_name}<br>${new Date(data.start_time).toString()}`);

    // Find the minimum and maximum timestamps.
    const minTimestamp = Math.min(...timestamps);
    const maxTimestamp = Math.max(...timestamps);

    const data = [
      {
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
      },
    ];

    const layout = {
      title: title,
      hovermode: 'closest',
      xaxis: {
        title: "iRating",
      },
      yaxis: {
        title: {
          text:'Best lap time during the race',
          standoff: 20,
        },
        tickformat: '%M:%S.%2f'
      },
    };

    Plotly.newPlot(container, data, layout, {responsive: true});
    loadingText.classList.add("hidden");

  } catch (e) {
    console.log(e);
    loadingText.textContent = "Unexpected error";
  }
}

const containers = document.querySelectorAll('.plot-container');

containers.forEach(container => {
  createPlot(container);
});
