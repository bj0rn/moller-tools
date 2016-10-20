#!/bin/bash
set -o pipefail


NEXUS_URL=$1
ARTIFACT_ID=$2
GROUP_ID=$3
VERSION=$4



if [ -z "$NEXUS_URL" ]; then
    echo "Need to set NEXUS_URL"
    exit -1
fi  

if [ -z "$ARTIFACT_ID" ]; then
    echo "Need to set ARTIFACT_ID"
    exit -1
fi

if [ -z "$GROUP_ID" ]; then  
    echo "Need to set GROUP_ID" 
    exit -1
fi

if [ -z "$VERSION" ]; then  
   echo "Need to set VERSION"
   exit -1
fi

if [ -z "$DOCKER_BASE" ]; then
   DOCKER_BASE="openjdk"
fi

if [ -z  "$OUTPUT_REGISTRY" ]; then
    OUTPUT_REGISTRY="test"
fi

if [ -z "$OUTPUT_IMAGE" ]; then
    OUTPUT_IMAGE="test"
fi


function generate_dockerfile(){
    local DOCKER_BASE=$1
    local BUILD_FOLDER=$2
    APP="app.jar"

    echo  "Docker base ${DOCKER_BASE}"

cat > $BUILD_FOLDER/Dockerfile <<EOF
FROM $DOCKER_BASE
COPY app.jar /app
ENTRYPOINT ["java", "-jar"  "app.jar"]
EOF

cat ${BUILD_FOLDER}/Dockerfile

}



function build_and_push(){
    local DOCKER_BASE=$1
    local OUTPUT_REGISTRY=$2
    local OUTPUT_IMAGE=$3
    local VERSION=$4
    local BUILD_FOLDER=$5

    echo "docker base ${DOCKER_BASE}"

    generate_dockerfile \
        "${DOCKER_BASE}" \
        "${BUILD_FOLDER}"

    docker build -t ${OUTPUT_REGISTRY}/${OUTPUT_IMAGE} ${BUILD_FOLDER}
    docker tag ${OUTPUT_REGISTRY}/${OUTPUT_IMAGE} ${OUTPUT_REGISTRY}/${OUTPUT_IMAGE}:${VERSION}
    docker push ${OUTPUT_REGISTRY}/${OUTPUT_IMAGE}:${VERSION}
}

function fetch_from_nexus(){
    local NEXUS_URL=$1
    local ARTIFACT_ID=$2
    local GROUP_ID=$3
    local VERSION=$4
    local BUILD_FOLDER=$5

    echo Artifact id ${ARTIFACT_ID}
    echo Group id ${GROUP_ID}
    echo version ${VERSION}
    echo download nexus ${BUILD_FOLDER}
    echo nexus_url ${NEXUS_URL}

    curl -o "${BUILD_FOLDER}/app.jar" ${NEXUS_URL}
}

BUILD_FOLDER=$(mktemp -d)
echo $BUILD_FOLDER

fetch_from_nexus \
    "${NEXUS_URL}" \
    "${ARTIFACT_ID}" \
    "${GROUP_ID}" \
    "${VERSION}" \
    "${BUILD_FOLDER}"


build_and_push \
	"${DOCKER_BASE}" \
	"${OUTPUT_REGISTRY}" \
	"${OUTPUT_IMAGE}" \
	"${VERSION}" \
	"${BUILD_FOLDER}"

