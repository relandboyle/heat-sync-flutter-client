# HeatSync
### Stay warm.

[![Netlify Status](https://api.netlify.com/api/v1/badges/ffaccc36-3c6d-4fc1-8c0b-54dbcfc71b69/deploy-status)](https://app.netlify.com/sites/heat-sync/deploys)

<a href="https://heat-sync.net/" target="_blank">HeatSync</a>

This application is a web client designed to interface with the HeatSync server.

The server collects time-series temperature data from IoT-enabled sensors placed in rent-stabilized apartment units throughout New York City.

It is unfortunately quite common for NYC landlords to deprive their tenants of heat and hot water during the colder months of the year. While tenants may report the condition, the behavior typically goes unpunished. City inspectors arrive on the scene days or weeks after a complaint is lodged, and if they cannot observe a hazardous condition then no violation can be issued.

HeatSync empowers tenants, tenants' associations, and their legal representatives to collect accurate, complete temperature data for any number of units. Reports and charts my be viewed in real-time or exported for use in a legal setting.

The HeatSync client is a Flutter Material application, deployed and hosted at <a href="https://netlify.com" target="_blank">Netlify.com</a>. It makes use of the fl_charts, google_fonts, firebase_auth, and provider packages among others.
