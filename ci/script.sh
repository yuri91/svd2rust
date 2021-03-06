set -ex

test_svd() {
    curl -L \
         https://raw.githubusercontent.com/posborne/cmsis-svd/python-0.4/data/$1/${2}.svd \
         > $td/${2}.svd
    target/$TARGET/release/svd2rust -i $td/${2}.svd > $td/src/lib.rs
    cargo build --manifest-path $td/Cargo.toml
}

main() {
    cross build --target $TARGET
    cross build --target $TARGET --release

    if [ ! -z $DISABLE_TESTS ]; then
        return
    fi

    case $TRAVIS_OS_NAME in
        linux)
            td=$(mktemp -d)
            ;;
        osx)
            td=$(mktemp -d -t tmp)
            ;;
    esac

    # test crate
    cargo init --name foo $td
    echo 'cortex-m = "0.2.0"' >> $td/Cargo.toml
    echo 'vcell = "0.1.0"' >> $td/Cargo.toml

    test_svd Nordic nrf51
    test_svd STMicro STM32F100xx
    test_svd STMicro STM32F103xx
    test_svd STMicro STM32F30x

    rm -rf $td
}

if [ -z $TRAVIS_TAG ]; then
    main
fi
