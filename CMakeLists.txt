cmake_minimum_required(VERSION 3.19)
project(MyFirstApp LANGUAGES CXX)

find_package(Qt6 6.5 REQUIRED COMPONENTS Core)
find_package(Qt6 REQUIRED COMPONENTS Core)

qt_standard_project_setup()

qt_add_executable(MyFirstApp
    main.cpp
    Task.h Task.cpp
)

target_link_libraries(MyFirstApp
    PRIVATE
        Qt::Core
)
target_link_libraries(MyFirstApp PRIVATE Qt6::Core)

include(GNUInstallDirs)

install(TARGETS MyFirstApp
    BUNDLE  DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
