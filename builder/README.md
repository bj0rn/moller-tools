Run the builder locally


docker run \
    -e NEXUS_URL=https://nexus.com/ \
    -e GROUP_ID=org.java.super \
    -e ARTIFACT_ID=app \
    -e VERSION=1.0.0 \
    -e DOCKER_BASE_IMAGE=uil0map-paas-app01.skead.no:5000/aurora/alpine-java8 \
    -e OUTPUT_REGISTRY=registry.com \
    -e OUTPUT_IMAGE=app-image
    -v /var/run/docker.sock:/var/run/docker.sock aurora/leveransepakkebygger
