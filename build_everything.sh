#!/bin/bash
[[ `docker-compose --version | awk '{print $3}'` == "1.19.0," ]] && echo "docker-compose is ok: 1.19.0" || echo "ERROR: DOCKER COMPOSE VERSION SHOULD BE 1.19.0!"

set -e

function usage {
    echo "Usage: $0 [--no-build] [--dev]"
}

DISABLE_BUILD=0
DEV_MODE=0

while [[ "$#" > 0 ]]; do case $1 in
    -h)
        usage
        exit 0
        ;;
    --no-build)
        DISABLE_BUILD=1
        shift
        ;;
    --dev)
        DEV_MODE=1
        shift
        ;;
    *)
        usage
        exit 1
        ;;
  esac;
done


if ((!$DISABLE_BUILD)); then
	echo "BUILDING docker-compiler-csharpnodes";
	(cd docker-neo-csharp-nodes; ./docker_build.sh)

	echo "BUILDING docker-neo-compiler-neo-python";
	(cd docker-neo-python; ./docker_build.sh)
fi

if (($DEV_MODE)); then
	echo "(DEV MODE) BUILDING docker-compiler-csharpnodes with modified neo-cli";
	(cd docker-neo-csharp-nodes; ./docker_build.sh --neo-cli neo-cli-built.zip)
fi

echo "BUILDING/RUNNING Neo-CSharp-Nodes with NeoScan-Docker (docker-compose with images from hub.docker)";
(cd dockers-neo-scan-neon; ./buildRun_Compose_PrivateNet_NeoScanDocker.sh)


echo "PROCEEDING. NeoCompiler Eco(system) has been built!";

echo "BUILDING/RUNNING web interface and compilers";
./buildRun_WebInterface_Compilers.sh
