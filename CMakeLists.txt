cmake_minimum_required(VERSION 3.24)
project(WinterTD VERSION 0.2.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(GODOTCPP_API_VERSION "4.7" CACHE STRING "Godot API version" FORCE)
set(GODOTCPP_TARGET "template_debug" CACHE STRING "Godot target" FORCE)

include(FetchContent)
FetchContent_Declare(godot_cpp
    GIT_REPOSITORY https://github.com/godotengine/godot-cpp.git
    GIT_TAG 10.0.0-stable
    GIT_SHALLOW TRUE
)
FetchContent_MakeAvailable(godot_cpp)

add_library(wintertd SHARED
    src/register_types.cpp
    src/camera/winter_camera_rig.cpp
    src/gameplay/creep_demo_mover.cpp
)
target_include_directories(wintertd PRIVATE src)
target_link_libraries(wintertd PRIVATE godot::cpp)
set_target_properties(wintertd PROPERTIES
    PREFIX ""
    OUTPUT_NAME "wintertd"
    LIBRARY_OUTPUT_DIRECTORY "$<1:${CMAKE_CURRENT_SOURCE_DIR}/project/bin>"
    RUNTIME_OUTPUT_DIRECTORY "$<1:${CMAKE_CURRENT_SOURCE_DIR}/project/bin>"
)
