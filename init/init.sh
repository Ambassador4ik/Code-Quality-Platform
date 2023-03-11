rm -rf data && mkdir data
rm -rf output && mkdir output
cd data
mkdir input output builder-output compiler-output tests checker-output
cd ..
cp -a tests/. data/tests

cd data
touch .env
cat <<EOT >> .env
INPUT_DIR="./input/"
BUILDER_OUTPUT_DIR="./builder-output/"
QODANA_OUTPUT_DIR="./output/"
COMPILER_OUTPUT_DIR="./compiler-output/"
TESTS_INPUT_DIR="./tests/"
CHECKER_OUTPUT_DIR="./checker-output/"
EOT

touch docker-compose.yaml
cat <<EOT >> docker-compose.yaml
version: "3"
services:
    project-builder:
        image: ambassador4ik/dotnet-solution-restore
        volumes:
            - \${INPUT_DIR}:/input/
            - \${BUILDER_OUTPUT_DIR}:/output/

    qodana:
        image: jetbrains/qodana-dotnet
        volumes:
            - \${BUILDER_OUTPUT_DIR}:/data/project/
            - \${QODANA_OUTPUT_DIR}:/data/results/
        command:
            - --save-report
        depends_on:
            project-builder:
                condition: service_completed_successfully

    compiler:
        image: ambassador4ik/dotnet-compiler
        volumes:
            - \${BUILDER_OUTPUT_DIR}:/input/
            - \${COMPILER_OUTPUT_DIR}:/output/
        depends_on:
            project-builder:
                condition: service_completed_successfully
    checker:
        image: ambassador4ik/dotnet-checker
        volumes:
            - \${COMPILER_OUTPUT_DIR}:/compiler-output/
            - \${TESTS_INPUT_DIR}:/input/
            - \${CHECKER_OUTPUT_DIR}:/output/
        depends_on:
            compiler:
                condition: service_completed_successfully
EOT

cd ..
cp -a input/. data/input

cd data
docker-compose up
docker-compose down

cd ..
cp -r data/checker-output/out.json output
cp data/output/report/results/result-allProblems.json output/result-allProblems.json
rm -rf data
