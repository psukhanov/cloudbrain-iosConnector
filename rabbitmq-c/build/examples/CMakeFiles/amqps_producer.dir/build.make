# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.4

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list


# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /Applications/CMake.app/Contents/bin/cmake

# The command to remove a file.
RM = /Applications/CMake.app/Contents/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /Users/a/code/cloudbrain-iosConnector/rabbitmq-c

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /Users/a/code/cloudbrain-iosConnector/rabbitmq-c/build

# Include any dependencies generated for this target.
include examples/CMakeFiles/amqps_producer.dir/depend.make

# Include the progress variables for this target.
include examples/CMakeFiles/amqps_producer.dir/progress.make

# Include the compile flags for this target's objects.
include examples/CMakeFiles/amqps_producer.dir/flags.make

examples/CMakeFiles/amqps_producer.dir/amqps_producer.c.o: examples/CMakeFiles/amqps_producer.dir/flags.make
examples/CMakeFiles/amqps_producer.dir/amqps_producer.c.o: ../examples/amqps_producer.c
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/a/code/cloudbrain-iosConnector/rabbitmq-c/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building C object examples/CMakeFiles/amqps_producer.dir/amqps_producer.c.o"
	cd /Users/a/code/cloudbrain-iosConnector/rabbitmq-c/build/examples && /usr/bin/gcc  $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -o CMakeFiles/amqps_producer.dir/amqps_producer.c.o   -c /Users/a/code/cloudbrain-iosConnector/rabbitmq-c/examples/amqps_producer.c

examples/CMakeFiles/amqps_producer.dir/amqps_producer.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/amqps_producer.dir/amqps_producer.c.i"
	$(CMAKE_COMMAND) -E cmake_unimplemented_variable CMAKE_C_CREATE_PREPROCESSED_SOURCE

examples/CMakeFiles/amqps_producer.dir/amqps_producer.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/amqps_producer.dir/amqps_producer.c.s"
	$(CMAKE_COMMAND) -E cmake_unimplemented_variable CMAKE_C_CREATE_ASSEMBLY_SOURCE

examples/CMakeFiles/amqps_producer.dir/amqps_producer.c.o.requires:

.PHONY : examples/CMakeFiles/amqps_producer.dir/amqps_producer.c.o.requires

examples/CMakeFiles/amqps_producer.dir/amqps_producer.c.o.provides: examples/CMakeFiles/amqps_producer.dir/amqps_producer.c.o.requires
	$(MAKE) -f examples/CMakeFiles/amqps_producer.dir/build.make examples/CMakeFiles/amqps_producer.dir/amqps_producer.c.o.provides.build
.PHONY : examples/CMakeFiles/amqps_producer.dir/amqps_producer.c.o.provides

examples/CMakeFiles/amqps_producer.dir/amqps_producer.c.o.provides.build: examples/CMakeFiles/amqps_producer.dir/amqps_producer.c.o


examples/CMakeFiles/amqps_producer.dir/utils.c.o: examples/CMakeFiles/amqps_producer.dir/flags.make
examples/CMakeFiles/amqps_producer.dir/utils.c.o: ../examples/utils.c
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/a/code/cloudbrain-iosConnector/rabbitmq-c/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Building C object examples/CMakeFiles/amqps_producer.dir/utils.c.o"
	cd /Users/a/code/cloudbrain-iosConnector/rabbitmq-c/build/examples && /usr/bin/gcc  $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -o CMakeFiles/amqps_producer.dir/utils.c.o   -c /Users/a/code/cloudbrain-iosConnector/rabbitmq-c/examples/utils.c

examples/CMakeFiles/amqps_producer.dir/utils.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/amqps_producer.dir/utils.c.i"
	$(CMAKE_COMMAND) -E cmake_unimplemented_variable CMAKE_C_CREATE_PREPROCESSED_SOURCE

examples/CMakeFiles/amqps_producer.dir/utils.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/amqps_producer.dir/utils.c.s"
	$(CMAKE_COMMAND) -E cmake_unimplemented_variable CMAKE_C_CREATE_ASSEMBLY_SOURCE

examples/CMakeFiles/amqps_producer.dir/utils.c.o.requires:

.PHONY : examples/CMakeFiles/amqps_producer.dir/utils.c.o.requires

examples/CMakeFiles/amqps_producer.dir/utils.c.o.provides: examples/CMakeFiles/amqps_producer.dir/utils.c.o.requires
	$(MAKE) -f examples/CMakeFiles/amqps_producer.dir/build.make examples/CMakeFiles/amqps_producer.dir/utils.c.o.provides.build
.PHONY : examples/CMakeFiles/amqps_producer.dir/utils.c.o.provides

examples/CMakeFiles/amqps_producer.dir/utils.c.o.provides.build: examples/CMakeFiles/amqps_producer.dir/utils.c.o


examples/CMakeFiles/amqps_producer.dir/unix/platform_utils.c.o: examples/CMakeFiles/amqps_producer.dir/flags.make
examples/CMakeFiles/amqps_producer.dir/unix/platform_utils.c.o: ../examples/unix/platform_utils.c
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/a/code/cloudbrain-iosConnector/rabbitmq-c/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_3) "Building C object examples/CMakeFiles/amqps_producer.dir/unix/platform_utils.c.o"
	cd /Users/a/code/cloudbrain-iosConnector/rabbitmq-c/build/examples && /usr/bin/gcc  $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -o CMakeFiles/amqps_producer.dir/unix/platform_utils.c.o   -c /Users/a/code/cloudbrain-iosConnector/rabbitmq-c/examples/unix/platform_utils.c

examples/CMakeFiles/amqps_producer.dir/unix/platform_utils.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/amqps_producer.dir/unix/platform_utils.c.i"
	$(CMAKE_COMMAND) -E cmake_unimplemented_variable CMAKE_C_CREATE_PREPROCESSED_SOURCE

examples/CMakeFiles/amqps_producer.dir/unix/platform_utils.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/amqps_producer.dir/unix/platform_utils.c.s"
	$(CMAKE_COMMAND) -E cmake_unimplemented_variable CMAKE_C_CREATE_ASSEMBLY_SOURCE

examples/CMakeFiles/amqps_producer.dir/unix/platform_utils.c.o.requires:

.PHONY : examples/CMakeFiles/amqps_producer.dir/unix/platform_utils.c.o.requires

examples/CMakeFiles/amqps_producer.dir/unix/platform_utils.c.o.provides: examples/CMakeFiles/amqps_producer.dir/unix/platform_utils.c.o.requires
	$(MAKE) -f examples/CMakeFiles/amqps_producer.dir/build.make examples/CMakeFiles/amqps_producer.dir/unix/platform_utils.c.o.provides.build
.PHONY : examples/CMakeFiles/amqps_producer.dir/unix/platform_utils.c.o.provides

examples/CMakeFiles/amqps_producer.dir/unix/platform_utils.c.o.provides.build: examples/CMakeFiles/amqps_producer.dir/unix/platform_utils.c.o


# Object files for target amqps_producer
amqps_producer_OBJECTS = \
"CMakeFiles/amqps_producer.dir/amqps_producer.c.o" \
"CMakeFiles/amqps_producer.dir/utils.c.o" \
"CMakeFiles/amqps_producer.dir/unix/platform_utils.c.o"

# External object files for target amqps_producer
amqps_producer_EXTERNAL_OBJECTS =

examples/amqps_producer: examples/CMakeFiles/amqps_producer.dir/amqps_producer.c.o
examples/amqps_producer: examples/CMakeFiles/amqps_producer.dir/utils.c.o
examples/amqps_producer: examples/CMakeFiles/amqps_producer.dir/unix/platform_utils.c.o
examples/amqps_producer: examples/CMakeFiles/amqps_producer.dir/build.make
examples/amqps_producer: librabbitmq/librabbitmq.4.1.4.dylib
examples/amqps_producer: examples/CMakeFiles/amqps_producer.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/Users/a/code/cloudbrain-iosConnector/rabbitmq-c/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_4) "Linking C executable amqps_producer"
	cd /Users/a/code/cloudbrain-iosConnector/rabbitmq-c/build/examples && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/amqps_producer.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
examples/CMakeFiles/amqps_producer.dir/build: examples/amqps_producer

.PHONY : examples/CMakeFiles/amqps_producer.dir/build

examples/CMakeFiles/amqps_producer.dir/requires: examples/CMakeFiles/amqps_producer.dir/amqps_producer.c.o.requires
examples/CMakeFiles/amqps_producer.dir/requires: examples/CMakeFiles/amqps_producer.dir/utils.c.o.requires
examples/CMakeFiles/amqps_producer.dir/requires: examples/CMakeFiles/amqps_producer.dir/unix/platform_utils.c.o.requires

.PHONY : examples/CMakeFiles/amqps_producer.dir/requires

examples/CMakeFiles/amqps_producer.dir/clean:
	cd /Users/a/code/cloudbrain-iosConnector/rabbitmq-c/build/examples && $(CMAKE_COMMAND) -P CMakeFiles/amqps_producer.dir/cmake_clean.cmake
.PHONY : examples/CMakeFiles/amqps_producer.dir/clean

examples/CMakeFiles/amqps_producer.dir/depend:
	cd /Users/a/code/cloudbrain-iosConnector/rabbitmq-c/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Users/a/code/cloudbrain-iosConnector/rabbitmq-c /Users/a/code/cloudbrain-iosConnector/rabbitmq-c/examples /Users/a/code/cloudbrain-iosConnector/rabbitmq-c/build /Users/a/code/cloudbrain-iosConnector/rabbitmq-c/build/examples /Users/a/code/cloudbrain-iosConnector/rabbitmq-c/build/examples/CMakeFiles/amqps_producer.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : examples/CMakeFiles/amqps_producer.dir/depend
