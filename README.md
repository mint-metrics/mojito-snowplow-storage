# Mojito Snowplow Storage

Snowplow Storage is comprised of two key areas:

1. ```./events```: Self-describing events emitted from experiments
2. ```./redshift-datamodels```: SQL data models for attributing ```conversions``` back to treatment ```exposures```


## Getting started

You'll need to add three things to your Enrichment pipeline:

1. [Add JSON schema to your Iglu](./events/jsonschema)
2. [Place the JSON paths files in your JSON paths folder](./events/jsonpaths)
3. [Create the tables in Redshift for loading shredded events](./events/sql)
4. [Setup SQL Runner to load your report tables each day](./redshift-datamodels)


## Thinking behind the events & data model

In the beginning we used Snowplow's Structured Events for tracking experiments. This worked well but we struggled to keep track of the naming conventions of events. Then, Self-Describing events came out in Snowplow a few years back and we migrated over our recipe_exposure events.

Over the years, we've refined our recipe exposure events from tracking lots of little details, like first exposures, namespaces, recipe IDs and other frivalous details. But what we've come to realise is that most of those small details are useless to collect when clients demand insights from experiments. We're better off focussing our time analysing behaviour of subjects in experiment treatments than we are trying to analyse minor details about the experiment.

Therefore, we collect just three broad types of events:

 - Recipe exposures: When subjects are exposed to the experiment
 - Conversions: Regular Snowplow events like page views and transactions to use as your success metrics
 - Recipe errors: Details about the error caused by a particular treatment and its stack trace - so you can fix it


## Why not use contexts?

Many in the Snowplow community use custom contexts attached to every event tracked by the client. I think this is both wasteful and limits your analysis.

It's wasteful because every event recorded will have an exposure context, taking up precious space inside your cluster (particularly Dense Compute ones). 

And it's limiting because not all relevant events will get a custom context attached - think about cookie churn and now ITP 2.1 expiring client-side-set cookies prematurely. Ultimately, we're headed for a world of ID stitching, and those events without contexts are going to send your experiment subjects dark after they're stitched together.

But we can still build tables to get the first exposure for a test and compute exposures for ID-stitched users! Sure, you can. But who's going to bother when 90% of the events are 

## Future work

We intend to support Google Big Query in the future as we need. So far, we only support Redshift as it's the default storage target for Mint Metrics' clients.

## Get involved

Let us know if you encounter any issues and reach out to us if you need a hand getting set up.

* [Open an issue on Github](https://github.com/mint-metrics/mojito-snowplow-storage/issues/new)
* [Mint Metrics' website](https://mintmetrics.io/)