#
# Copyright (c) 2014-2024, NVIDIA CORPORATION. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.


include(../../donut/compileshaders.cmake)
file(GLOB shaders "*.hlsl")
file(GLOB sources "*.cpp" "*.h")

set(project aftermath_sample)
set(folder "Examples/Aftermath")

donut_compile_shaders_all_platforms(
    TARGET ${project}_shaders
    PROJECT_NAME "Aftermath"
    CONFIG ${CMAKE_CURRENT_SOURCE_DIR}/shaders.cfg
    FOLDER ${folder}
    OUTPUT_BASE ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/shaders/${project}
# applications using Aftermath need to set the --embedPDB option when compiling shaders
# without it, NSight will not be able to resolve back to original source (only to shader IL)
    SHADERMAKE_OPTIONS --embedPDB
)

add_executable(${project} WIN32 ${sources})
target_link_libraries(${project} donut_app donut_engine)
add_dependencies(${project} ${project}_shaders)
set_target_properties(${project} PROPERTIES FOLDER ${folder})

if (MSVC)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W3 /MP")
endif()

if (WIN32)
    add_custom_command( TARGET ${project} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy ${AFTERMATH_RUNTIME_LIBRARY} $<TARGET_FILE_DIR:${project}>
        COMMAND_EXPAND_LISTS )
else()
    add_custom_command( TARGET ${project} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy ${AFTERMATH_LIBRARY} $<TARGET_FILE_DIR:${project}>
        COMMAND_EXPAND_LISTS )
endif()
