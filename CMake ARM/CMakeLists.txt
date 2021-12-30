cmake_minimum_required(VERSION 3.18.0)
set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

set(CWD ${CMAKE_CURRENT_SOURCE_DIR})
set(CMSIS ${CWD}/cmsis)
set(CORE ${CWD}/core)
set(CMAKE_TOOLCHAIN_FILE ${CWD}/arm-none-eabi-gcc.cmake)

project(PROJ_NAME C)

file(GLOB CMSIS_INC
    "${CMSIS}/core_XX.h"
    "${CMSIS}/core_XXFunc.h"
    "${CMSIS}/core_XXInstr.h"
    "${CMSIS}/FAMILY_FILE.h"
    "${CMSIS}/CHIP_FILE.h")

file(GLOB PROJ_SOURCE
    "${CORE}/src/main.c"
    "${CORE}/src/usb_descriptors.c"
    "${CORE}/src/startup_XX.c"
    "${CORE}/src/system_XX.c")

file(GLOB PROJ_INC)

set(LINKER_PATH "${CWD}/linker/LINKER.ld")

enable_language(C ASM)
set(CMAKE_C_STANDARD 11)

set(EXECUTABLE ${PROJECT_NAME}.elf)
add_executable(${EXECUTABLE} ${PROJ_SOURCE} ${PROJ_INC} ${CMSIS_INC})

target_include_directories(${EXECUTABLE} PRIVATE
    cmsis
    cmsis/component
    cmsis/instance
    cmsis/pio
    core/inc
    core/src)

target_compile_definitions(${EXECUTABLE} PRIVATE
    -DDEBUG
    -DF_CPU=XXXX
    -DDONT_USE_CMSIS_INIT 
    -D__CHIP_NAME__)

target_compile_options(${EXECUTABLE} PRIVATE
    -W 
    -Wall 
    -Wextra
    -Werror
    --std=gnu11 
    -g
    -O0
    -fno-diagnostics-show-caret
    -fdata-sections 
    -ffunction-sections
    -funsigned-char 
    -funsigned-bitfields
    -mcpu=cortex-CORE
    -mthumb)

target_link_options(${EXECUTABLE} PRIVATE
    -mcpu=cortex-CORE 
    -mthumb
    -Wl,--gc-sections
    -Wl,--script=${LINKER_PATH})

set(OUTPUT_FILE ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${PROJECT_NAME})

add_custom_command(TARGET ${EXECUTABLE}
    POST_BUILD
    COMMAND arm-none-eabi-size --format=sysv ${OUTPUT_FILE}.elf)

# Create hex file
add_custom_command(TARGET ${EXECUTABLE}
    POST_BUILD
    COMMAND arm-none-eabi-objcopy -O ihex ${OUTPUT_FILE}.elf ${OUTPUT_FILE}.hex
    COMMAND arm-none-eabi-objcopy -O binary ${OUTPUT_FILE}.elf ${OUTPUT_FILE}.bin)