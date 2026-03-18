# Thanks to Job Vranish (https://spin.atomicobject.com/2016/08/26/makefile-c-projects/)
TARGET_EXEC := hello-world-c

BUILD_DIR := ./build
SRC_DIRS := ./src

# Find all the C, C++, and Assembly files we want to compile
SRCS := $(shell find $(SRC_DIRS) -name '*.cpp' -or -name '*.c' -or -name '*.s')

# Prepends BUILD_DIR and appends .o to every src file
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)

# String substitution (suffix version without %).
DEPS := $(OBJS:.o=.d)

# Every folder in ./src will need to be passed to GCC so that it can find header files
INC_DIRS := $(shell find $(SRC_DIRS) -type d)
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

# The -MMD and -MP flags together generate Makefiles for us!
CPPFLAGS := $(INC_FLAGS) -MMD -MP

# Best Practice: Use ?= for easy overriding from the command line/environment
PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin

# The final build step.
$(BUILD_DIR)/$(TARGET_EXEC): $(OBJS)
	$(CXX) $(OBJS) -o $@ $(LDFLAGS)

# Build step for C source
$(BUILD_DIR)/%.c.o: %.c
	mkdir -p $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

# Build step for C++ source
$(BUILD_DIR)/%.cpp.o: %.cpp
	mkdir -p $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

# Build step for Assembly source (Added because *.s is included in SRCS)
$(BUILD_DIR)/%.s.o: %.s
	mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) -c $< -o $@

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)

.PHONY: install
install: $(BUILD_DIR)/$(TARGET_EXEC)
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 $(BUILD_DIR)/$(TARGET_EXEC) $(DESTDIR)$(BINDIR)/

# Include the .d makefiles.
-include $(DEPS)