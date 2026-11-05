cmake_minimum_required(VERSION 3.20)

project(anolis_provider_template_cpp VERSION 0.1.0 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# The C++ provider SDK, consumed as source from a pinned release tarball. It
# brings the ADPP messages (anolis::adpp_proto) and the protocol pin with it, so
# the provider declares neither. To build against a local SDK checkout:
#   cmake --preset release -DFETCHCONTENT_SOURCE_DIR_ANOLIS_PROVIDER_SDK=<path>
include(FetchContent)
FetchContent_Declare(
    anolis_provider_sdk
    URL https://github.com/anolishq/anolis-provider-sdk/releases/download/v0.6.0/anolis-provider-sdk-0.6.0-source.tar.gz
    URL_HASH SHA256=620ed8ebc92063d08adbc3617de59e87830ca2eb9fe47fc118d92441b0910d20
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
)
FetchContent_MakeAvailable(anolis_provider_sdk)

add_executable(anolis-provider-template-cpp src/provider.cpp)
target_link_libraries(anolis-provider-template-cpp PRIVATE anolis::provider_sdk anolis::provider_sdk_config)
target_compile_definitions(anolis-provider-template-cpp PRIVATE ANOLIS_PROVIDER_VERSION="${PROJECT_VERSION}")

if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(anolis-provider-template-cpp PRIVATE -Wall -Wextra -Wpedantic)
    if(ANOLIS_PROVIDER_WARNINGS_AS_ERRORS)
        target_compile_options(anolis-provider-template-cpp PRIVATE -Werror)
    endif()
endif()
