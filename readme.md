# New Zealand population: One pixel per person visualisation

A simple visualisation of the total New Zealand population in the 2013 Census at a scale of one pixel per person, by ethnicity and region of residence.

`process-nz-pop-data.R` processes the raw data file from Statistics New Zealand into a clean format.

`index.html` has D3 code for the visualisation. Canvas is used rather than SVG due to the size of the images. A number of tricks were required to maintain the 1:1 ratio between people and pixels on both retina and non-retina screens. 
