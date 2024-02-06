#
# Makefile
# WARNING: relies on invocation setting current working directory to Makefile location
# This is done in .vscode/task.json
#
PROJECT 			?= lvgl-sdl
MAKEFLAGS 			:= -j $(shell nproc)
SRC_EXT      			:= c
CXXSRC_EXT      		:= cpp
OBJ_EXT				:= o
CC 				?= gcc
CXX				?= g++

SRC_DIR				:= ./
WORKING_DIR			:= ./build
BUILD_DIR			:= $(WORKING_DIR)/obj
BIN_DIR				:= $(WORKING_DIR)/bin
UI_DIR 				:= ui

# REMOVED FOLLOWING :: -Wmaybe-uninitialized  -Wno-discarded-qualifiers  -Wstack-usage=2048  -Wclobbered
#   ADDED FOLLOWING :: -Wuninitialized        -Wno-ignored-qualifiers    -Wstack-protector

WARNINGS 			:= -Wall -Wextra \
						-Wshadow -Wundef -Wuninitialized -Wmissing-prototypes -Wno-ignored-qualifiers \
						-Wno-unused-function -Wno-error=strict-prototypes -Wpointer-arith -fno-strict-aliasing -Wno-error=cpp -Wuninitialized \
						-Wno-unused-parameter -Wno-missing-field-initializers -Wno-format-nonliteral -Wno-cast-qual -Wunreachable-code -Wno-switch-default  \
					  	-Wreturn-type -Wmultichar -Wformat-security -Wno-ignored-qualifiers -Wno-error=pedantic -Wno-sign-compare -Wno-error=missing-prototypes -Wdouble-promotion -Wdeprecated  \
						-Wempty-body -Wshift-negative-value \
            			-Wtype-limits -Wsizeof-pointer-memaccess -Wpointer-arith -Wstack-protector

CFLAGS 				:= -O0 -g $(WARNINGS)
CXXFLAGS 			:= -std=c++20 -fpermissive

# Add simulator define to allow modification of source
DEFINES				:= -D SIMULATOR=1 -D LV_BUILD_TEST=0

# Include simulator inc folder first so lv_conf.h from custom UI can be used instead
INC 				:= -I./ui/simulator/inc/ -I./ -I./lvgl/ -I./lvglpp/src/
LDLIBS	 			:= -lSDL2 -lm
BIN 				:= $(BIN_DIR)/demo

COMPILE				= $(CC) $(CFLAGS) $(INC) $(DEFINES)
CXXCOMPILE			= $(CXX) $(CXXFLAGS) $(INC) $(DEFINES)

# Automatically include all source files

#CXX_SOURCES = $(wildcard *.cpp)
#C_SOURCES = $(wildcard *.c)
C_SOURCES 			:= $(shell find $(SRC_DIR) -type f -name '*.c' -not -path '*/\.*')
CXX_SOURCES			:= $(shell find $(SRC_DIR) -type f -name '*.cpp' -not -path '*/\.*')

C_OBJECTS    			:= $(patsubst $(SRC_DIR)%,$(BUILD_DIR)/%,$(C_SOURCES:.$(SRC_EXT)=.$(OBJ_EXT)))
CXX_OBJECTS    			:= $(patsubst $(SRC_DIR)%,$(BUILD_DIR)/%,$(CXX_SOURCES:.$(CXXSRC_EXT)=.$(OBJ_EXT)))

all: default

$(BUILD_DIR)/%.$(OBJ_EXT): $(SRC_DIR)/%.$(SRC_EXT)
	@echo 'Building project file: $<'
	@mkdir -p $(dir $@)
	@$(COMPILE) -c -o "$@" "$<"

$(BUILD_DIR)/%.$(OBJ_EXT): $(SRC_DIR)/%.$(CXXSRC_EXT)
	@echo 'Building project file: $<'
	@mkdir -p $(dir $@)
	@$(CXXCOMPILE) -c -o "$@" "$<"

default: $(C_OBJECTS) $(CXX_OBJECTS)
	@mkdir -p $(BIN_DIR)
	$(CXX) -o $(BIN) $(C_OBJECTS) $(CXX_OBJECTS) $(LDFLAGS) ${LDLIBS}

clean:
	rm -rf $(WORKING_DIR)

install: ${BIN}
	install -d ${DESTDIR}/usr/lib/${PROJECT}/bin
	install $< ${DESTDIR}/usr/lib/${PROJECT}/bin/
