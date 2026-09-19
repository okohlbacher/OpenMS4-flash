cmake_minimum_required(VERSION 3.24)
project(OpenMSFLASH VERSION 1.0.0 LANGUAGES CXX)
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)
include(GenerateExportHeader)
include(CTest)
include(cmake/OpenMS4Dependencies.cmake)
if(BUILD_TESTING)
  openms4_find_core(COMPONENTS TestSupport)
else()
  openms4_find_core()
endif()
openms4_source_revision(OpenMSFLASH_SOURCE_REVISION OpenMSFLASH_SOURCE_DIRTY)
add_library(OpenMS_FLASH SHARED
  source/ANALYSIS/TOPDOWN/FLASHDeconvAlgorithm.cpp
  source/ANALYSIS/TOPDOWN/SpectralDeconvolution.cpp
  source/ANALYSIS/TOPDOWN/MassFeatureTrace.cpp
  source/ANALYSIS/TOPDOWN/Qvalue.cpp
  source/ANALYSIS/TOPDOWN/TopDownIsobaricQuantification.cpp)
add_library(OpenMS::FLASH ALIAS OpenMS_FLASH)

# MSVC reports C4244 from inside <xutility> for Core's ClusterHierarchical::cluster, which takes
# the bin size as double and hands it to BinnedSpectrum's float parameter. The conversion is in an
# imported Core header, so no change here can silence it individually; drop the suppression once
# Core casts at that call site. GCC and Clang do not report it: they see Core as a system include.
if(OPENMS4_WARNINGS_AS_ERRORS AND MSVC)
  target_compile_options(OpenMS_FLASH PRIVATE /wd4244)
endif()
set_target_properties(OpenMS_FLASH PROPERTIES EXPORT_NAME FLASH VERSION ${PROJECT_VERSION} SOVERSION 1)
target_compile_features(OpenMS_FLASH PUBLIC cxx_std_23)
target_link_libraries(OpenMS_FLASH PUBLIC OpenMS::Core PRIVATE Eigen3::Eigen)
if(OpenMS_WITH_OPENMP)
  target_link_libraries(OpenMS_FLASH PRIVATE OpenMP::OpenMP_CXX)
endif()
generate_export_header(OpenMS_FLASH
  EXPORT_FILE_NAME generated/OpenMS/ANALYSIS/TOPDOWN/OpenMSFLASHConfig.h
  EXPORT_MACRO_NAME OPENMSFLASH_DLLAPI)
target_include_directories(OpenMS_FLASH PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/generated>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
openms4_install_rpath(OpenMS_FLASH)
install(TARGETS OpenMS_FLASH EXPORT OpenMSFLASHTargets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})
install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/generated/OpenMS/ANALYSIS/TOPDOWN/OpenMSFLASHConfig.h
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/OpenMS/ANALYSIS/TOPDOWN)
configure_package_config_file(cmake/OpenMSFLASHConfig.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/OpenMSFLASHConfig.cmake
  INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/OpenMSFLASH)
write_basic_package_version_file(${CMAKE_CURRENT_BINARY_DIR}/OpenMSFLASHConfigVersion.cmake
  VERSION ${PROJECT_VERSION} COMPATIBILITY ExactVersion)
install(EXPORT OpenMSFLASHTargets NAMESPACE OpenMS:: DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/OpenMSFLASH)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/OpenMSFLASHConfig.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/OpenMSFLASHConfigVersion.cmake
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/OpenMSFLASH)

if(BUILD_TESTING)
  set(CF_OPENMS_TEST_DATA_PATH "${CMAKE_CURRENT_SOURCE_DIR}/tests/data/")
  configure_file(tests/test_config.h.in generated/OpenMS/test_config.h @ONLY)
  foreach(name FLASHDeconvAlgorithm SpectralDeconvolution MassFeatureTrace DeconvolvedSpectrum_integration TopDownIsobaricQuantification)
    add_executable(${name}_test tests/source/${name}_test.cpp ${OpenMS_TEST_SUPPORT_SOURCE})
    target_link_libraries(${name}_test PRIVATE OpenMS::FLASH OpenMS::TestFramework)
    target_include_directories(${name}_test PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/generated)
    add_test(NAME ${name}_test COMMAND ${name}_test)
  endforeach()
endif()

option(OPENMSFLASH_BUILD_TOOLS "Build the FLASH command-line tools" ON)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin/$<0:>")
if(OPENMSFLASH_BUILD_TOOLS)
  openms4_find_package(OpenMSCLI)
  if(BUILD_TESTING)
    find_package(Python3 REQUIRED COMPONENTS Interpreter)
  endif()
  include(cmake/OpenMS4Tools.cmake)
  openms4_load_tools(package_tools)
  foreach(tool IN LISTS package_tools)
    add_executable(${tool} src/${tool}.cpp)
    target_link_libraries(${tool} PRIVATE OpenMS::CLI OpenMS::FLASH)
  endforeach()
  openms4_install_tools(flash bin ${package_tools})
endif()
option(OPENMS4_REGRESSION_TESTS "Enable installed fixture regression tests" OFF)
if(OPENMS4_REGRESSION_TESTS)
  if(NOT OPENMSFLASH_BUILD_TOOLS)
    message(FATAL_ERROR "FLASH tool regression tests require OPENMSFLASH_BUILD_TOOLS=ON")
  endif()
  openms4_find_package(OpenMSTestData)
  find_package(Python3 REQUIRED COMPONENTS Interpreter)
  add_test(NAME TOPP_FLASHDeconv_1 COMMAND $<TARGET_FILE:FLASHDeconv> -test
    -in ${OpenMSTestData_TOPP_DIR}/FLASHDeconv_sample_input.mzML -out ${CMAKE_CURRENT_BINARY_DIR}/FLASHDeconv_1.tsv -keep_empty_out)
  add_test(NAME TOPP_FLASHDeconv_1_science COMMAND ${Python3_EXECUTABLE}
    ${CMAKE_CURRENT_SOURCE_DIR}/tests/compare_features.py
    ${CMAKE_CURRENT_BINARY_DIR}/FLASHDeconv_1.tsv
    ${CMAKE_CURRENT_SOURCE_DIR}/tests/data/FLASHDeconv_sample_pre_refactor.tsv)
  set_tests_properties(TOPP_FLASHDeconv_1_science PROPERTIES DEPENDS TOPP_FLASHDeconv_1)
  set_tests_properties(TOPP_FLASHDeconv_1 PROPERTIES ENVIRONMENT "OPENMS_TOOL_PREFIX_PATH=${CMAKE_BINARY_DIR};OPENMS_DISABLE_UPDATE_CHECK=ON")
endif()
