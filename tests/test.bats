#!/usr/bin/env bats

IMAGE_NAME="mt5-compiler-test"

setup() {
    chmod o+w tests
    rm -f tests/*.ex5
    # Build image before tests to ensure it exists and is up to date
    # We rely on Docker caching to make this fast if already built
    if [[ -z "${SKIP_BUILD}" ]]; then
        docker build -t "$IMAGE_NAME" .
        export SKIP_BUILD=true
    fi
}

teardown() {
    rm -f tests/*.ex5
}

@test "Success Case: Compile valid MQ5 file" {
    rm -f tests/Success.ex5
    run docker run --rm -v "$(pwd)/tests:/home/wine/tests" "$IMAGE_NAME" /home/wine/tests/Success.mq5
    
    echo "$output"
    [[ "$output" =~ "Compilation successful." ]]
    [ "$status" -eq 0 ]
    [ -f "tests/Success.ex5" ]
}

@test "Failure Case: Compile invalid MQ5 file" {
    run docker run --rm -v "$(pwd)/tests:/home/wine/tests" "$IMAGE_NAME" /home/wine/tests/Fail.mq5
    
    echo "$output"
    [[ "$output" == *"Compilation failed."* ]]
    [ "$status" -ne 0 ]
    [ ! -f "tests/Fail.ex5" ]
}
