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
    const containerWidth = container.clientWidth;
    const containerHeight = containerWidth * (9 / 16);
    const xValues = points.map(data => data.irating);
    const yValues = points.map(data => new Date(data.lap_time / 10));

    const data = [
      {
        x: xValues,
        y: yValues,

        mode: 'markers',
        type: 'scatter',
      },
    ];

    const layout = {
      title: title,
      width: containerWidth,
      height: containerHeight,
      autosize: false,
      xaxis: {
        title: "iRating",
      },
      yaxis: {
        title: {
          text:'Best lap time during the race',
          standoff: 20,
        },
        tickformat: '%M:%S.%2f'
      }
    };

    Plotly.newPlot(container, data, layout);
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
