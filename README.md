# Mojito Snowplow Storage

Simple experiment events & data models to power analysis in [Mojito R Analytics](https://github.com/mint-metrics/mojito-r-analytics) and other tools. 

There are two parts to this repository:

1. **Events** (```./events```): Self-describing events emitted from experiments
2. **Data models** ```./redshift-datamodels```: SQL data models for attributing ```conversions``` back to variant ```exposures``` in reporting


## Prerequisites

 - Snowplow running with Redshift as a storage target
 - Snowplow's SQL Runner app


## Getting started

[Add the events to your Iglu](https://discourse.snowplowanalytics.com/t/introductory-guide-to-creating-your-own-self-describing-events-and-contexts-tutorial/1377) and [setup your data modelling steps in SQL Runner](https://github.com/snowplow/sql-runner/wiki/Guide-for-analysts):

1. [Add JSON schema to your Iglu](./events/jsonschema)
    - This is required for event validation and shredding during enrichment
2. (Redshift only) [Put the JSON paths files in your JSON paths folder](./events/jsonpaths)
    - If running Redshift, this maps the JSON keys to your table fields
3. (Redshift only) [Create the tables in Redshift for loading shredded events](./events/sql)
    - If running Redshift, this is the table definition that shredded events will populate
4. Setup SQL Runner to load your report tables each day ([Redshift data models](./redshift-datamodels))
    - This step creates the data model used for reporting


## Mojito's three core events

For most experiment reports, we're interested in just three events:

1. Exposures (or assignments)
2. Failures (errors in experiment variants, shared code or triggers)
3. Conversions (e.g. clicks, page views, purchases or leads)

### 1. Recipe exposures (assignment)

These events are tracked approximately when users get assigned or bucketed into a test group. We use this to establish the time and group each user is in, so any future conversions can be attributed to the test.

Starting in 2013, we used Snowplow's Structured Events for tracking experiments. This worked well for a while but we struggled to keep track of the naming conventions of events and keep fields. Then, Self-Describing events came out in Snowplow a few years back and we migrated over our recipe_exposure events.

Our initial self describing events tracked many fields (like whether the exposure was a users' first, namespaces, recipe IDs and other frivalous details) all of which we never used in reports. Since then, our events evolved into simpler schemas focussing on the core fields needed for experiments. This saves data warehouse space and analysts' time worrying about useless fields.

Mojito recipe exposures collect just:

 - **Wave ID**: A canonical ID of the test used in cookies and in experiment in reports (one day, the Wave ID may become part of the PRNG seed for deterministic assignment)
 - **Wave name**: The "pretty" name of an experiment for high-level reports usability
 - **Recipe**: The "pretty" name of a recipe that's also used in reports


### 2. Recipe failures (error tracking)

In complex builds, it's hard to avoid errors firing from experiment variants (such as obscure browsers, products with unusual features or deployments breaking tests mid-way through). Errors can mean the difference between your treatment working or breaking. 

In any case, by tracking this data into experiment reports lets you keep abreast of issues and even helps you fix them.

The data collected for recipe failures are:

 - **Wave ID**: A canonical ID of the test used in cookies and in experiment in reports
 - **Wave name**: The "pretty" name of an experiment
 - **Component**: The recipe name or trigger where the error was emanating from
 - **Error**: The error message and stack (if available)

If you use [Snowplow's UA Parser enrichment](https://github.com/snowplow/snowplow/wiki/ua-parser-enrichment), be sure to use our `recipe_errors` data model (TBC) for some basic debugging information at the ready. It works great in Superset & R!


### 3. Conversions (every other event)

No specific conversion events exist for Mojito. 

Instead, we treat any of Snowplow's rich, high-fidelity events as conversions (why re-invent the wheel?). We often select a subset of conversion events to keep reports responsive, such as:

 - Transactions (and revenue)
 - Leads
 - Other ecommerce events

Even though we select all conversion events into the conversion tables, our reports ensure proper causality and attribution. Only conversions after a subject's first exposure are attributed to the experiment. Then, we can say: Treatment (`Cause`) -> Conversion (`Effect`)

Snowplow data is insanely rich that it opens the floodgates to better analyses than you could perform with just Optimizely/VWO datasets. 

## Why not use contexts for exposure tracking?

Many in the Snowplow community use custom contexts attached to every event tracked by the client. I think this is wasteful.

If you're running Dense Compute Redshift nodes, space is a premium. Passing a context alongside every event uses more space in your contexts table than is necessary. You can always perform the experiment-conversion-attribution server-side, just like on Mojito, and save disk space.

Besides, perhaps the test cookies were set on one domain and not transferred to the domain the conversion took place on. Or perhaps you want to stitch together different Snowplow User IDs and need to attribute conversions across devices.

By performing attribution server-side, you're not limited by your data collection setup.

## Future work

We intend to support GCP/BigQuery in the future as we need, but for now, we only support Redshift.

## Get involved

Let us know if you encounter any issues and reach out to us if you need a hand getting set up.

* [Open an issue on Github](https://github.com/mint-metrics/mojito-snowplow-storage/issues/new)
* [Mint Metrics' website](https://mintmetrics.io/)