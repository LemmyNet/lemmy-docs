# Prometheus Metrics

Lemmy supports the export of metrics in the [Prometheus](https://prometheus.io/)
format. This document outlines how to enable the feature and begin collecting
metrics.

## Configuration

Configuration of the Prometheus endpoint is contained under the optional
`prometheus` object in the `lemmy.hjson` file. In this configuration block, the
`bind` address and `port` of the Prometheus metrics server can be configured.

By default, it will serve on `127.0.0.1:10002`. If running inside a container,
it should instead bind on all addresses as below.

```
prometheus: {
  bind: "0.0.0.0"
  port: 10002
}
```

## Scrape

After Lemmy has been deployed, test that it is serving properly
(substitute the correct hostname if not running locally).

```shell
curl localhost:10002/metrics
```

### Prometheus Configuration

Below is a minimal configuration on the Prometheus server's side that will
scrape the metrics from Lemmy.

```yaml
global:
scrape_configs:
  - job_name: lemmy
    scrape_interval: 1m
    static_configs:
      - targets:
          - localhost:10002
```

Then run a Prometheus server to scrape the metrics.

```shell
docker run -p 9090:9090 -v prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus
```

If Lemmy was deployed using the `docker-compose.yml`, then use the following
configurations instead.

```yaml
global:
scrape_configs:
  - job_name: lemmy
    scrape_interval: 1m
    static_configs:
      - targets:
          - lemmy:10002
```

Run the Prometheus server inside the same docker network that Lemmy is running
in. This can be discovered by running `docker inspect` on the lemmy container.

```shell
docker run -p 9090:9090 -v prometheus.yml:/etc/prometheus/prometheus.yml --network $LEMMY_NETWORK prom/prometheus
```

## Example

Below is an example of what is returned from the `/metrics` endpoint. Each
combination of `endpoint`, `method`, and `status` will produce a histogram
(`lemmy_api_http_requests_duration_seconds_*`), so for brevity the output was
reduced to a single endpoint.

For the HTTP metrics, this is saying that `/api/v3/post/list` received 12 `GET`
requests that returned a `200` HTTP code. Cumulatively, these requests took
0.383 seconds. 5 requests completed between 0.01 and 0.025 seconds. 5 more
completed between 0.025 and 0.05 seconds. And the remaining 2 requests completed
between 0.05 and 0.1 seconds.

```
lemmy_api_http_requests_duration_seconds_bucket{endpoint="/api/v3/post/list",method="GET",status="200",le="0.005"} 0
lemmy_api_http_requests_duration_seconds_bucket{endpoint="/api/v3/post/list",method="GET",status="200",le="0.01"} 0
lemmy_api_http_requests_duration_seconds_bucket{endpoint="/api/v3/post/list",method="GET",status="200",le="0.025"} 5
lemmy_api_http_requests_duration_seconds_bucket{endpoint="/api/v3/post/list",method="GET",status="200",le="0.05"} 10
lemmy_api_http_requests_duration_seconds_bucket{endpoint="/api/v3/post/list",method="GET",status="200",le="0.1"} 12
lemmy_api_http_requests_duration_seconds_bucket{endpoint="/api/v3/post/list",method="GET",status="200",le="0.25"} 12
lemmy_api_http_requests_duration_seconds_bucket{endpoint="/api/v3/post/list",method="GET",status="200",le="0.5"} 12
lemmy_api_http_requests_duration_seconds_bucket{endpoint="/api/v3/post/list",method="GET",status="200",le="1"} 12
lemmy_api_http_requests_duration_seconds_bucket{endpoint="/api/v3/post/list",method="GET",status="200",le="2.5"} 12
lemmy_api_http_requests_duration_seconds_bucket{endpoint="/api/v3/post/list",method="GET",status="200",le="5"} 12
lemmy_api_http_requests_duration_seconds_bucket{endpoint="/api/v3/post/list",method="GET",status="200",le="10"} 12
lemmy_api_http_requests_duration_seconds_bucket{endpoint="/api/v3/post/list",method="GET",status="200",le="+Inf"} 12
lemmy_api_http_requests_duration_seconds_sum{endpoint="/api/v3/post/list",method="GET",status="200"} 0.3834808429999999
lemmy_api_http_requests_duration_seconds_count{endpoint="/api/v3/post/list",method="GET",status="200"} 12

lemmy_api_http_requests_total{endpoint="/api/v3/post/list",method="GET",status="200"} 12

# HELP lemmy_db_pool_available_connections Number of available connections in the pool
# TYPE lemmy_db_pool_available_connections gauge
lemmy_db_pool_available_connections 2
# HELP lemmy_db_pool_connections Current number of connections in the pool
# TYPE lemmy_db_pool_connections gauge
lemmy_db_pool_connections 2
# HELP lemmy_db_pool_max_connections Maximum number of connections in the pool
# TYPE lemmy_db_pool_max_connections gauge
lemmy_db_pool_max_connections 5

# HELP process_cpu_seconds_total Total user and system CPU time spent in seconds.
# TYPE process_cpu_seconds_total counter
process_cpu_seconds_total 14
# HELP process_max_fds Maximum number of open file descriptors.
# TYPE process_max_fds gauge
process_max_fds 1073741816
# HELP process_open_fds Number of open file descriptors.
# TYPE process_open_fds gauge
process_open_fds 91
# HELP process_resident_memory_bytes Resident memory size in bytes.
# TYPE process_resident_memory_bytes gauge
process_resident_memory_bytes 75603968
# HELP process_start_time_seconds Start time of the process since unix epoch in seconds.
# TYPE process_start_time_seconds gauge
process_start_time_seconds 1688487611
# HELP process_threads Number of OS threads in the process.
# TYPE process_threads gauge
process_threads 37
# HELP process_virtual_memory_bytes Virtual memory size in bytes.
# TYPE process_virtual_memory_bytes gauge
process_virtual_memory_bytes 206000128
```
