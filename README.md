# Realtime Data Streaming | End-to-End Data Engineering Project

## Table of Contents
- [Introduction](#introduction)
- [System Architecture](#system-architecture)

## Introduction

This project provides a complete guide to building a data transformation pipeline using dbt and SQL on Google BigQuery. It covers every step, from loading raw data to transforming it into an optimized format for analysis. Leveraging dbt for effective data modeling and transformation, along with Google BigQuery for fast, serverless SQL queries, this project demonstrates how to efficiently manage and process data in a fully-managed warehouse environment.


## System Architecture


![System Architecture](https://github.com/beto1810/Glamira_DE/blob/master/frame_work.png)

<div style="display: flex; justify-content: space-between;">
    <img src="https://github.com/beto1810/Glamira_DE/blob/e832fb63e16ce2dc5be2d3a46516320b9cfff773/model.png" alt="Image" width="500" height="440">
    <img src="https://github.com/beto1810/Glamira_DE/blob/e832fb63e16ce2dc5be2d3a46516320b9cfff773/looker.png" alt="Image" width="500" height="440">
</div>

--

The project is designed with the following components:

- **Data Source**: Jason Sale File with over 40 mil rows of transaction and product data from the Glamira website
- **Google Cloud Storage**: Used for storing the raw data.
- **Google Cloud VM**: Virtual Machine set up for data scraping and processing.
- **Google Function & Pub/Sub**: Handle triggers and automate processing tasks.
- **Google Big Query**:  Serves as the data warehouse for efficient querying and storage.
- **DBT**: Used for data transformation and modeling.
- **Looker** : To Visualization tool of transformed data.


