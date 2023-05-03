# Kafka Streams Sandbox

## Features

- Single helm install command to test Kafka streams on Kubernetes
    - Installs the following -
        - Prometheus operator
        - Grafana, if enabled
    - Run Kafka Streams JAR
- Integrated monitoring with Prometheus and Grafana or other monitoring solutions that support Prometheus remote write
    - Scraps JMX metrics with an exporter
    - Built in custom Grafana dashboard for streams with 
    - Enable ingress for Prometheus/Grafana

## Usage

1. Running streams jar

There are 2 ways to configure streams jars with the helm chart.

### Using a custom docker image (Recommended)

- Build a custom docker image with the jar file. The image should run the jar file as its CMD or ENTRYPOINT.

Example Dockerfile - 
```dockerfile
FROM openjdk:19-jdk
WORKDIR /app

COPY target/word-count-1.0-SNAPSHOT-jar-with-dependencies.jar .

CMD java -jar word-count-1.0-SNAPSHOT-jar-with-dependencies.jar /etc/config/streams.properties
```
- Set the `image` property of `streams` section in the values.yaml to the image name and tag of the custom image
- If you're using a private image, define `streams.imagePullSecrets` and `imageCredentials`


### Providing a JAR file

> TODO

2. Defining Configuration Properties
> TODO
3. Defining environment variables
> TODO
4. Running stateful streams
> TODO

## Examples

- Custom image

```yaml
streams:
  image: username/kafka-streams-word-count:1.0
```

- Defining configuration properties

```yaml
streams:
  configProperties:
    properties: |
      application.id=word-count
      bootstrap.servers=pkc-xxxxx.us-west4.gcp.confluent.cloud:9092
      security.protocol=SASL_SSL
      sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username='XXXXXXXXXXXXXXXX' password='YYYYYYYYY+YYYYYYY/YYYYYYYYYYYYYYY/YYYYYYYYYYYYYYYYYYYYYYYYYYYYYY';
      sasl.mechanism=PLAIN
      auto.reset.config=earliest
      input.topic.name=word-count-input
      output.topic.name=word-count-output
    filename: streams.properties
    path: /etc/config
```

- Defining environment variables

```yaml
streams:
  env:
  - name: INPUT_TOPIC
    value: input-topic
```

- Private custom image for streams

```yaml
streams:
  image: quay.io/someone/kafka-streams-word-count:1.0
  imagePullSecrets:
    registry: quay.io
    username: someone
    password: sillyness
```

- Stateful data

```yaml
streams:
  statefulData:
    enabled: true
    path: /data/data-source
    storage: 1Gi
    storageClassName: "standard"
```

- Ingress for Prometheus and Grafana

```yaml
kube-prometheus-stack:
  prometheus:
    ingress:
      enabled: true
      ingressClassName: nginx
      hosts:
        - prometheus.mydomain.com
      paths:
        - /
      pathType: ImplementationSpecific
      ## TLS configuration for Prometheus Ingress
      ## Secret must be manually created in the namespace
      ##
      tls: []
        # - secretName: prometheus-general-tls
        #   hosts:
        #     - prometheus.example.com
  grafana:
    ingress:
      enabled: true
      ingressClassName: nginx
      hosts:
        - grafana.mydomain.com
      paths:
        - /
      pathType: ImplementationSpecific
      ## TLS configuration for Grafana Ingress
      ## Secret must be manually created in the namespace
      ##
      tls: []
        # - secretName: grafana-general-tls
        #   hosts:
        #     - grafana.example.com
```

- Remote monitoring tool with Prometheus Remote Write support

```yaml
kube-prometheus-stack:
  prometheus:
    prometheusSpec:
      ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#remotewritespec
      ## example for New Relic
      ##
      remoteWrite:
      - url: https://metric-api.newrelic.com/prometheus/v1/write?prometheus_server=kafka-streams-sandbox
        bearerToken: xxxxxxxxxxxxxxxxxxxxxxx
  ## Optionally, disable grafana since a remote monitoring solution is used
  grafana:
    enabled: false
```

