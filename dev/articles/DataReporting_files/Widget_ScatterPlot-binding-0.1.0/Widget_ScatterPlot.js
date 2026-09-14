HTMLWidgets.widget({
    name: 'Widget_ScatterPlot',
    type: 'output',
    factory: function(el, width, height) {
        return {
            renderValue: function(input) {
                if (input.bDebug)
                    console.log(input);

                // Coerce `input.lChartConfig` to an object if it is not already.
                if (Object.prototype.toString.call(input.lChartConfig) !== '[object Object]') {
                    input.lChartConfig = {};
                };

                // Readable data-derived id for report-level wiring - but never
                // rename a Shiny output (the outputId is what the server keys
                // on), and keep the htmlwidgets id as a suffix so repeated
                // metrics on one page stay unique.
                if (!HTMLWidgets.shinyMode) {
                    el.id = `scatterPlot--${input.lChartConfig.MetricID}--${el.id}`;
                }

                // Add click event callback to chart.
                input.lChartConfig.clickCallback = clickCallback(el, input);

                // Generate scatter plot.
                const instance = gsmViz.default.scatterPlot(
                    el,
                    input.dfResults,
                    input.lChartConfig,
                    input.dfBounds,
                    input.dfGroups
                );

                // Add dropdowns that highlight group ID(s).
                addWidgetControls(
                    el,
                    input.dfResults,
                    input.lChartConfig,
                    input.dfGroups,
                    input.bAddGroupSelect,
                    false
                );

                // Add a footnote below the scatter plot.
                const footnote = document.createElement('div'); // Create a div for the footnote.
                footnote.style.fontSize = '10px'; // Set a smaller font size for the footnote.
                footnote.style.color = '#555'; // Use a lighter color for the footnote text.

                // Set the content of the footnote from the input.
                footnote.innerHTML = input.strFootnote; // Use the footnote passed from R.

                // Append the footnote div to the element containing the scatter plot.
                el.appendChild(footnote);
            },
            resize: function(width, height) {
            }
        };
    }
});
