# CMake configuration for 16KB page size support
cmake_minimum_required(VERSION 3.18.1)

# Set 16KB page size alignment
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DANDROID_PAGE_SIZE_AGNOSTIC=ON")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DANDROID_PAGE_SIZE_AGNOSTIC=ON")

# Set linker flags for 16KB alignment
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-z,page-size=16384")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-z,page-size=16384")

# Set section alignment for 16KB pages
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--section-start=.text=0x4000")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--section-start=.data=0x4000")

# Enable page size agnostic compilation
add_definitions(-DANDROID_PAGE_SIZE_AGNOSTIC=ON)
add_definitions(-DANDROID_PAGE_SIZE=16384)
